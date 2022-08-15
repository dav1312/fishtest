(() => {
  // Get all the divs with should-use-number-of-lines attribute
  const divs = document.querySelectorAll("[should-use-number-of-lines]");

  // Loop through all the divs
  divs.forEach((div) => {
    // Get the div with collapsed attribute
    const collapsedDiv = div.querySelector("[collapsed]");

    // Get the button with class more
    const moreBtn = div.querySelector(".more");

    // Get the button with class less
    const lessBtn = div.querySelector(".less");

    // Get the element with class expander
    const expander = div.querySelector(".expander");

    // If the expander has more lines than the max lines specified in the div style attribute then show the more button
    if (expander.scrollHeight > expander.clientHeight) {
      moreBtn.hidden = false;
    }

    console.log(expander.scrollHeight, expander.clientHeight);

    // Add event listener to the more button
    moreBtn.addEventListener("click", () => {
      // Remove the collapsed attribute
      collapsedDiv.removeAttribute("collapsed");

      // Hide the more button
      moreBtn.hidden = true;

      // Show the less button
      lessBtn.hidden = false;
    });

    // Add event listener to the less button
    lessBtn.addEventListener("click", () => {
      // Add the collapsed attribute
      collapsedDiv.setAttribute("collapsed", "");

      // Show the more button
      moreBtn.hidden = false;

      // Hide the less button
      lessBtn.hidden = true;
    });

    // Add event listener to the window
    window.addEventListener("resize", () => {
      // If the expander has more lines than the max lines specified in the div style attribute then show the more button
      if (expander.scrollHeight > expander.clientHeight) {
        moreBtn.hidden = false;
      } else {
        // Hide the more button
        moreBtn.hidden = true;

        // Hide the less button
        lessBtn.hidden = true;
      }
    });
  });
})();
