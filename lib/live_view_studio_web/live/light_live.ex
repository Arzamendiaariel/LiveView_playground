defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view
  # mounting the component
  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000", color: "#F1C40D")
    {:ok, socket}
  end

  # rendering the component
  # def render(assigns) do
  #   ~H"""
  #   <h1>Front Porch Light</h1>
  #   <div id="light">
  #     <div class="meter">
  #       <span style={ "width:#{ @brightness}%"}><%= @brightness %> %</span>
  #     </div>
  #     <button phx-click="off">
  #       <img src="/images/light-off.svg" alt="" />
  #     </button>
  #     <button phx-click="down">
  #       <img src="/images/down.svg" alt="" />
  #     </button>
  #     <button phx-click="random">
  #       <img src="/images/fire.svg" alt="" />
  #     </button>
  #     <button phx-click="up">
  #       <img src="/images/up.svg" alt="" />
  #     </button>
  #     <button phx-click="on">
  #       <img src="/images/light-on.svg" alt="" />
  #     </button>
  #   </div>
  #   """
  # end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={ "width:#{ @brightness}%; background-color: #{@color}"}>
          <%= @brightness %> %
        </span>
      </div>
      <form phx-change="change-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                id={temp}
                name="temp"
                value={temp}
                checked={temp == @temp}
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  # def render(assigns) do
  #   ~H"""
  #   <h1>Front Porch Light</h1>
  #   <div id="light">
  #     <form phx-change="reostato" phx-submit="on_off">
  #       <div class="meter">
  #         <span><%= @brightness %> %</span>
  #       </div>
  #       <input
  #         type="range"
  #         min="0"
  #         max="100"
  #         name="brightness"
  #         value={@brightness}
  #       />
  #       <button type="submit">
  #         <img src="/images/light-on.svg" alt="" /> /
  #         <img src="/images/light-off.svg" alt="" />
  #       </button>
  #     </form>
  #   </div>
  #   """
  # end

  # handling events

  def handle_event("change-temp", %{"temp" => t}, socket) do
    case t do
      "3000" -> {:noreply, assign(socket, temp: t, color: "#F1C40D")}
      "4000" -> {:noreply, assign(socket, temp: t, color: "#FEFF66")}
      "5000" -> {:noreply, assign(socket, temp: t, color: "#99CCFF")}
    end
  end

  # def handle_event("reostato", %{"brightness" => b}, socket) do
  #   {:noreply, assign(socket, brightness: b)}
  # end

  # def handle_event("on_off", _, socket) do
  #   case socket.assigns.brightness do
  #     x when x > 0 -> {:noreply, assign(socket, brightness: 0)}
  #     0 -> {:noreply, assign(socket, brightness: 100)}
  #   end
  # end

  # def handle_event("off", _params, socket) do
  #   socket = assign(socket, brightness: 0)

  #   {:noreply, socket}
  # end

  # def handle_event("up", _params, socket) do
  #   case socket.assigns.brightness do
  #     100 ->
  #       {:noreply, socket}

  #     _ ->
  #       {:noreply, update(socket, :brightness, &(&1 + 10))}
  #       # socket = update(socket, :brightness, &min(&1 + 10, 100))
  #       # {:noreply, socket}
  #   end
  # end

  # def handle_event("random", _params, socket) do
  #   case socket.assigns.brightness do
  #     100 ->
  #       {:noreply, socket}

  #     0 ->
  #       {:noreply, socket}

  #     _ ->
  #       {:noreply, assign(socket, :brightness, Enum.random(0..100))}
  #   end
  # end

  # def handle_event("down", _params, socket) do
  #   case socket.assigns.brightness do
  #     0 ->
  #       {:noreply, socket}

  #     _ ->
  #       {:noreply, update(socket, :brightness, &(&1 - 10))}
  #       # socket = update(socket, :brightness, &max(&1 - 10, 0))
  #       # {:noreply, socket}
  #   end
  # end

  # def handle_event("on", _params, socket) do
  #   socket = assign(socket, brightness: 100)
  #   {:noreply, socket}
  # end
end
