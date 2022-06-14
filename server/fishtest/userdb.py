import sys
import threading
import time
from datetime import datetime
import re

from pymongo import ASCENDING
import bcrypt

class UserDb:
    def __init__(self, db):
        self.db = db
        self.users = self.db["users"]
        self.user_cache = self.db["user_cache"]
        self.top_month = self.db["top_month"]
        self.flag_cache = self.db["flag_cache"]

    # Cache user lookups for 60s
    user_lock = threading.Lock()
    cache = {}

    def find(self, name):
        with self.user_lock:
            if name in self.cache:
                u = self.cache[name]
                if u["time"] > time.time() - 60:
                    return u["user"]
            user = self.users.find_one({"username": name})
            if not user:
                return None
            self.cache[name] = {"user": user, "time": time.time()}
            return user

    def clear_cache(self):
        with self.user_lock:
            self.cache.clear()

    def hash_password(self, password):
        return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(4))

    def check_password(self, password, hashed_password):
        return bcrypt.checkpw(password.encode("utf-8"), hashed_password)

    def authenticate(self, username, password):
        user = self.find(username)
        if not re.match(r"^\$2[ayb]\$[0-9]+\$.{53}$", user["password"]):
            user["password"] = self.hash_password(user["password"]).decode("utf-8")
            self.save_user(user)
        valid_password = self.check_password(password, user["password"].encode("utf-8"))

        if not user or not valid_password:
            sys.stderr.write("Invalid login: '{}' '{}'\n".format(username, password))
            return {"error": "Invalid password for user: {}".format(username)}
        if "blocked" in user and user["blocked"]:
            sys.stderr.write("Blocked login: '{}' '{}'\n".format(username, password))
            return {"error": "Account blocked for user: {}".format(username)}

        return {"username": username, "authenticated": True}

    def get_users(self):
        return self.users.find(sort=[("_id", ASCENDING)])

    # Cache pending for 1s
    last_pending_time = 0
    last_pending = None
    pending_lock = threading.Lock()

    def get_pending(self):
        with self.pending_lock:
            if time.time() > self.last_pending_time + 1:
                self.last_pending = list(
                    self.users.find({"blocked": True}, sort=[("_id", ASCENDING)])
                )
                self.last_pending_time = time.time()
            return self.last_pending

    def get_user(self, username):
        return self.find(username)

    def get_user_groups(self, username):
        user = self.find(username)
        if user:
            groups = user["groups"]
            return groups

    def add_user_group(self, username, group):
        user = self.find(username)
        user["groups"].append(group)
        self.users.replace_one({"_id": user["_id"]}, user)

    def create_user(self, username, password, email):
        try:
            if self.find(username):
                return False
            hashed_password = self.hash_password(password).decode("utf-8")
            self.users.insert_one(
                {
                    "username": username,
                    "password": hashed_password,
                    "registration_time": datetime.utcnow(),
                    "blocked": True,
                    "email": email,
                    "groups": [],
                    "tests_repo": "",
                }
            )
            self.last_pending_time = 0

            return True
        except:
            return False

    def save_user(self, user):
        self.users.replace_one({"_id": user["_id"]}, user)
        self.last_pending_time = 0

    def get_machine_limit(self, username):
        user = self.find(username)
        if user and "machine_limit" in user:
            return user["machine_limit"]
        return 16
