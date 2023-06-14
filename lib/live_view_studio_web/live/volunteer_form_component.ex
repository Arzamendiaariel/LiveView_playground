defmodule LiveViewStudioWeb.VolunteerFormComponent do

  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do

    changeset = Volunteers.change_volunteer(%Volunteer{})

    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(socket, assigns)
      # lo siguiente no es necesario, podria simplemente sumar 1 a @count en render, esto es para mostrar que update puede ser usado
      |> assign(:count, assigns.count + 1)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div>
      <div class="count">
      Go for it! You'll be volunteer n° # <%= @count %>
      </div>
        <.form for={@form} phx-submit="save" phx-change="live-validate" phx-target={@myself}>
          <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000"/>
          <.input field={@form[:phone]} type="tel" placeholder="Phone" autocomplete="off" phx-debounce="blur"/>
          <.button phx-disable-with="Saving...">
            Check In
          </.button>
        </.form>
      </div>
    """
  end

  def handle_event("live-validate", %{"volunteer" => volunteer_params}, socket) do

    changeset = %Volunteer{}
    |>Volunteers.change_volunteer( volunteer_params)
    |>Map.put(:action, :cualquier_nombre_de_atom_distinto_de_nil)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->

        send(self(), {:volunteer_created, volunteer})
        # socket = stream_insert(socket, :volunteers, volunteer, at: 0)

        socket = put_flash(socket, :info, "Volunteer successfully checked in!")

        changeset = Volunteers.change_volunteer(%Volunteer{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end


end
