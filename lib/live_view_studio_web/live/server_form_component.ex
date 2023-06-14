defmodule LiveViewStudioWeb.ServerFromComponent do

  use LiveViewStudioWeb, :live_component
  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
      form: to_form(changeset))

    {:ok, socket}
  end

  #no vamos a usar update/2 para mostrar que no es simpoer necesario

  def render(assigns) do
    ~H"""
      <div>
        <.form for={@form} phx-submit="save" phx-target={@myself}>
          <div class="field">
            <.input field={@form[:name]} placeholder="Name" />
          </div>
          <div class="field">
            <.input field={@form[:framework]} placeholder="Framework" />
          </div>
          <div class="field">
            <.input
              field={@form[:size]}
              placeholder="Size (MB)"
              type="number"
            />
          </div>
          <.button phx-disable-with="Saving...">
            Save
          </.button>
          <.link patch={~p"/servers"} class="cancel">
            Cancel
          </.link>
        </.form>
      </div>
    """
    end

    def handle_event("save", %{"server" => server_params}, socket) do
      case Servers.create_server(server_params) do
        {:ok, server} ->
          send(self(), {:server_created, server})


          {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    end

end
