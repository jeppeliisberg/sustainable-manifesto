module ApplicationHelper
  include Pagy::Frontend

  def nav_link_to(text, path)
    # Check if the current page is the path OR if we are on a principle page and the link is for the root path
    is_active = current_page?(path) || (controller_name == "principles" && path == root_path)

    active_class = is_active ? "text-teal-500 dark:text-teal-400 font-semibold" : "text-gray-700 dark:text-gray-300 hover:text-teal-600 dark:hover:text-teal-400"

    link_to text, path, class: "text-sm #{active_class} transition-colors"
  end
end
