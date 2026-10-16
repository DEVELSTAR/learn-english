// ActiveAdmin Vanilla JS support for Rails 8 & Propshaft (UJS & Batch Action handling)
document.addEventListener("DOMContentLoaded", () => {
  // 1. Handle data-method (e.g. data-method="delete") & data-confirm
  document.addEventListener("click", (e) => {
    const link = e.target.closest("a[data-method]");
    if (link) {
      const method = link.getAttribute("data-method").toLowerCase();
      if (method !== "get") {
        e.preventDefault();

        const confirmMsg = link.getAttribute("data-confirm") || link.getAttribute("data-turbo-confirm");
        if (confirmMsg && !window.confirm(confirmMsg)) {
          return false;
        }

        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
        const csrfParam = document.querySelector('meta[name="csrf-param"]')?.getAttribute("content") || "authenticity_token";

        const form = document.createElement("form");
        form.method = "POST";
        form.action = link.href;
        form.style.display = "none";

        if (csrfToken) {
          const csrfInput = document.createElement("input");
          csrfInput.type = "hidden";
          csrfInput.name = csrfParam;
          csrfInput.value = csrfToken;
          form.appendChild(csrfInput);
        }

        const methodInput = document.createElement("input");
        methodInput.type = "hidden";
        methodInput.name = "_method";
        methodInput.value = method;
        form.appendChild(methodInput);

        document.body.appendChild(form);
        form.submit();
        return;
      }
    }

    // Also handle links that ONLY have data-confirm without data-method
    const confirmLink = e.target.closest("a[data-confirm]:not([data-method])");
    if (confirmLink) {
      const confirmMsg = confirmLink.getAttribute("data-confirm");
      if (confirmMsg && !window.confirm(confirmMsg)) {
        e.preventDefault();
        return false;
      }
    }
  });

  // 2. Handle Table Checkbox Selection (Select All / Row Selection)
  const toggleAll = document.querySelector("input.toggle_all");
  const rowCheckboxes = document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all)");
  const batchActionSelector = document.querySelector(".batch_actions_selector");

  const updateBatchActions = () => {
    const checkedCount = document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all):checked").length;
    if (batchActionSelector) {
      const button = batchActionSelector.querySelector(".dropdown_menu_button");
      if (button) {
        if (checkedCount > 0) {
          button.classList.remove("disabled");
        } else {
          button.classList.add("disabled");
        }
      }
    }
  };

  if (toggleAll) {
    toggleAll.addEventListener("change", () => {
      rowCheckboxes.forEach((cb) => {
        cb.checked = toggleAll.checked;
        const row = cb.closest("tr");
        if (row) row.classList.toggle("selected", toggleAll.checked);
      });
      updateBatchActions();
    });

    rowCheckboxes.forEach((cb) => {
      cb.addEventListener("change", () => {
        const row = cb.closest("tr");
        if (row) row.classList.toggle("selected", cb.checked);
        const allChecked = Array.from(rowCheckboxes).every((c) => c.checked);
        const someChecked = Array.from(rowCheckboxes).some((c) => c.checked);
        toggleAll.checked = allChecked;
        toggleAll.indeterminate = someChecked && !allChecked;
        updateBatchActions();
      });
    });
  }

  // 3. Handle Batch Actions Dropdown & Submission
  if (batchActionSelector) {
    const button = batchActionSelector.querySelector(".dropdown_menu_button");
    const menuList = batchActionSelector.querySelector(".dropdown_menu_list_wrapper");

    if (button && menuList) {
      button.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (!button.classList.contains("disabled")) {
          menuList.style.display = menuList.style.display === "block" ? "none" : "block";
        }
      });

      document.addEventListener("click", () => {
        menuList.style.display = "none";
      });
    }

    const batchLinks = batchActionSelector.querySelectorAll("a.batch_action");
    batchLinks.forEach((link) => {
      link.addEventListener("click", (e) => {
        e.preventDefault();
        const action = link.getAttribute("data-action");
        const confirmMsg = link.getAttribute("data-confirm");

        if (confirmMsg && !window.confirm(confirmMsg)) {
          return false;
        }

        const batchActionInput = document.getElementById("batch_action");
        const form = document.getElementById("collection_selection");

        if (batchActionInput && form) {
          batchActionInput.value = action;
          form.submit();
        }
      });
    });
  }
});
