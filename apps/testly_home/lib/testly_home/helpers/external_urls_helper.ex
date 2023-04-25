defmodule TestlyHome.ExternalUrlsHelper do
  @external_urls Application.get_env(:testly_home, :external_urls)

  @project_url Keyword.fetch!(@external_urls, :project)
  @knowledgebase_url Keyword.fetch!(@external_urls, :knowledgebase)
  @customer_support_url Keyword.fetch!(@external_urls, :customer_support)
  @blog_url Keyword.fetch!(@external_urls, :blog)
  @affiliate_url Keyword.fetch!(@external_urls, :affiliate)
  @project_setup_url Keyword.fetch!(@external_urls, :project_setup)
  @testly_old_site_url Keyword.fetch!(@external_urls, :testly_old_site)

  def project_url(id) do
    String.replace(@project_url, ":project_id", id)
  end

  def project_setup_url(id) do
    String.replace(@project_setup_url, ":project_id", id)
  end

  def knowledgebase_url do
    @knowledgebase_url
  end

  def customer_support_url do
    @customer_support_url
  end

  def blog_url do
    @blog_url
  end

  def affiliate_url do
    @affiliate_url
  end

  def testly_old_site_url do
    @testly_old_site_url
  end
end
