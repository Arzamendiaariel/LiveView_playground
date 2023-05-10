defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        loading: false,
        matches: %{}
      )

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:el_carro, query})

    socket =
      assign(
        socket,
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest", %{"query" => prefix}, socket) do
    matches = Vehicles.suggest(prefix)

    socket =
      assign(
        socket,
        matches: matches
      )

    {:noreply, socket}
  end

  def handle_info({:el_carro, query}, socket) do
    socket =
      assign(
        socket,
        loading: false,
        vehicles: Vehicles.search(query)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
          list="matches"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>
      <datalist id="matches">
        <option :for={model <- @matches} value={model}>
          <%= model %>
        </option>
      </datalist>
      <.loader :if={@loading}/>
      <%!-- <div :if={@loading} class="loader"></div> --%>
      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
