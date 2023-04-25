defmodule TestlyHome.LegalController do
  use TestlyHome, :controller

  @spec legal(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def legal(conn, _params) do
    render(conn, "legal.html", hero_neutral: "Legal")
  end

  @spec policy(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def policy(conn, _params) do
    render(conn, "policy.html", hero_neutral: "Privacy Policy")
  end

  @spec terms(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def terms(conn, _params) do
    render(conn, "terms.html", hero_neutral: "Terms Of Use")
  end

  @spec disclaimer(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def disclaimer(conn, _params) do
    render(conn, "disclaimer.html", hero_neutral: "Earnings Disclaimer")
  end

  @spec agreement(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def agreement(conn, _params) do
    render(conn, "agreement.html", hero_neutral: "Affiliate Agreement")
  end
end
