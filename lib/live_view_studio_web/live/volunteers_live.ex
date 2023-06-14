defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    form = to_form(changeset)

    socket =
      socket
      # |> assign(:volunteers, volunteers)
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <%!-- <pre>
      <%= inspect @form, pretty: true %>
    </pre> --%>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} count={@count} />
      <div id="volunteers" phx-update="stream">
        <.volunteer :for={{id, volunteer} <- @streams.volunteers} volunteer={volunteer} id={id} />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}>
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click="toggle-status" phx-value-id={@volunteer.id} >
          <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
        </button>
      </div>
      <.link class="delete" phx-click="delete" phx-value-id={@volunteer.id} data-confirm="Are your sure?">
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end

  def handle_info({:volunteer_created, volunteer}, socket) do

    socket =
      stream_insert(socket, :volunteers, volunteer, at: 0)
      |> update(:count, &(&1 + 1))

    {:noreply, socket}
  end

  def handle_event("delete", %{"id"=> id}, socket) do

    volunteer = Volunteers.get_volunteer!(id)

    { :ok, _ } = Volunteers.delete_volunteer(volunteer)

    socket = stream_delete(socket, :volunteers, volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id"=> id}, socket) do

    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer } = Volunteers.toggle_status_volunteer(volunteer)
        # as the volunteer already exists in the dom we this will update the volunteer and not just insert it
        socket = stream_insert(socket,:volunteers, volunteer)
    {:noreply, socket}
  end


end
