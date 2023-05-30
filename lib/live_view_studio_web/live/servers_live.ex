defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    form = to_form(changeset)

    socket =
      assign(socket,
        servers: servers,
        selected_server: hd(servers),
        coffees: 0,
        form: form
      )

      {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    server = Servers.get_server!(id)
    {:noreply,
     assign(socket,
     selected_server: server,
     page_title: "What's up #{server.name}")}
  end
  def handle_params(_, _url, socket) do
    {:noreply, assign(socket, selected_server: hd(socket.assigns.servers))}
  end


  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <.form for={@form} phx-submit="save">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off"/>
        <.input field={@form[:size]} type="number" placeholder="Size" autocomplete="off"/>
        <.input field={@form[:framework]} placeholder="Framework" autocomplete="off"/>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
      </.form>
      <div class="sidebar">
        <div class="nav">
          <.link
            patch={~p"/servers/#{server}"}
            :for={server <- @servers}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <div class="server">
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <span class={@selected_server.status}>
                <%= @selected_server.status %>
              </span>
            </div>
            <div class="body">
              <div class="row">
                <span>
                  <%= @selected_server.deploy_count %> deploys
                </span>
                <span>
                  <%= @selected_server.size %> MB
                </span>
                <span>
                  <%= @selected_server.framework %>
                </span>
              </div>
              <h3>Last Commit Message:</h3>
              <blockquote>
                <%= @selected_server.last_commit_message %>
              </blockquote>
            </div>
          </div>
          <div class="links">
          <.link navigate={~p"/light"} >
          Adjunt Lights
          </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server"=> server_params}, socket) do
    case Servers.create_server(server_params)do
      {:error, changeset} ->
        socket = assign(socket, form: to_form(changeset))
        {:noreply, socket}
      {:ok, server} ->
        update(socket, :servers, fn servers -> [server | servers] end)
        changeset = Servers.change_server(%Server{})
        form = to_form(changeset)
        socket = assign(socket, form: form)
        {:noreply, socket}
    end
  end
end
