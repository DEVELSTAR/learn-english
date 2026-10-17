// ActiveAdmin Vanilla JS support for Rails 8 with Propshaft
(function() {
  "use strict";

  // Prevent multiple initializations
  if (window._activeAdminInitialized) return;
  window._activeAdminInitialized = true;

  // 1. Handle data-method (e.g. data-method="delete") & data-confirm
  document.addEventListener("click", function(event) {
    var link = event.target.closest("a[data-method]");
    if (!link) return;

    var method = (link.getAttribute("data-method") || "").toLowerCase();
    if (!method || method === "get") return;

    event.preventDefault();
    event.stopPropagation();

    var confirmMsg = link.getAttribute("data-confirm");
    if (confirmMsg && !window.confirm(confirmMsg)) {
      return false;
    }

    var csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ||
                    document.querySelector('input[name="authenticity_token"]')?.value || "";
    var csrfParam = document.querySelector('meta[name="csrf-param"]')?.getAttribute("content") || "authenticity_token";

    var form = document.createElement("form");
    form.method = "POST";
    form.action = link.href;
    form.style.display = "none";

    if (csrfToken) {
      var csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = csrfParam;
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    }

    var methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = method;
    form.appendChild(methodInput);

    document.body.appendChild(form);
    HTMLFormElement.prototype.submit.call(form);
    return false;
  }, true);

  // 2. Handle Batch Actions Dropdown & Links
  document.addEventListener("click", function(event) {
    // A. Batch action trigger link
    var batchLink = event.target.closest("a.batch_action");
    if (batchLink) {
      event.preventDefault();
      event.stopPropagation();
      var action = batchLink.getAttribute("data-action");
      var confirmMsg = batchLink.getAttribute("data-confirm");
      if (confirmMsg && !window.confirm(confirmMsg)) return false;

      var form = document.getElementById("collection_selection");
      var input = document.getElementById("batch_action");
      if (form && input) {
        input.value = action;
        HTMLFormElement.prototype.submit.call(form);
      }
      return false;
    }

    // B. Dropdown button
    var dropdownBtn = event.target.closest(".batch_actions_selector .dropdown_menu_button");
    if (dropdownBtn) {
      event.preventDefault();
      event.stopPropagation();
      if (!dropdownBtn.classList.contains("disabled")) {
        var menu = dropdownBtn.closest(".batch_actions_selector")?.querySelector(".dropdown_menu_list_wrapper");
        if (menu) {
          menu.style.display = (menu.style.display === "block") ? "none" : "block";
        }
      }
      return false;
    }

    // C. Click outside closes dropdowns
    document.querySelectorAll(".dropdown_menu_list_wrapper").forEach(function(m) {
      m.style.display = "none";
    });
  });

  // 3. Handle Checkbox toggles for Batch Actions
  document.addEventListener("change", function(event) {
    if (event.target.classList.contains("toggle_all")) {
      var isChecked = event.target.checked;
      document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all)").forEach(function(cb) {
        cb.checked = isChecked;
        var row = cb.closest("tr");
        if (row) row.classList.toggle("selected", isChecked);
      });
    } else if (event.target.closest(".paginated_collection") && event.target.type === "checkbox") {
      var row = event.target.closest("tr");
      if (row) row.classList.toggle("selected", event.target.checked);
    }

    var anyChecked = document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all):checked").length > 0;
    var button = document.querySelector(".batch_actions_selector .dropdown_menu_button");
    if (button) {
      if (anyChecked) {
        button.classList.remove("disabled");
      } else {
        button.classList.add("disabled");
      }
    }
  });
})();
