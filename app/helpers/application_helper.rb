module ApplicationHelper
  include Pagy::Frontend

  def nav_link_to(text, path)
    active_class = current_page?(path) ? "text-teal-500 dark:text-teal-400 font-semibold" : "text-gray-700 dark:text-gray-300 hover:text-teal-600 dark:hover:text-teal-400"

    link_to text, path, class: "text-sm #{active_class} transition-colors"
  end
end
