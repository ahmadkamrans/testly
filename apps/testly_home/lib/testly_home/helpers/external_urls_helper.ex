defmodule TestlyHome.ExternalUrlsHelper do
  def project_url(id) do
    String.replace(fetch!(:project), ":project_id", id)
  end

  def project_setup_url(id) do
    String.replace(fetch!(:project_setup), ":project_id", id)
  end

  def knowledgebase_url do
    fetch!(:knowledgebase)
  end

  def customer_support_url do
    fetch!(:customer_support)
  end

  def blog_url do
    fetch!(:blog)
  end

  def affiliate_url do
    fetch!(:affiliate)
  end

  def testly_old_site_url do
    fetch!(:testly_old_site)
  end

  defp fetch!(key) do
    Application.get_env(:testly_home, :external_urls)
    |> Keyword.fetch!(key)
  end
end
