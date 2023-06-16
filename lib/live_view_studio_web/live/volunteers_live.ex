defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do

    if connected?(socket) do
      Volunteers.subscribe()
    end

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
    <div class="bg-[#152433] text-[#a1bcd8] font-montserrat"> <!-- Puedes cambiar 'red' por el color que quieras en Tailwind -->
      <svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
            viewBox="0 0 3061.42 3061.42" style="background-color:inherit; fill: currentColor;" xml:space="preserve">
          <style type="text/css">
              .st0{font-family:'Montserrat';}
              .st1{font-size:181.0366px;}
              .st2{font-size:70.9456px;}
          </style>
          <g>
              <g>
                  <g>
                      <path d="M1207,1759.49c-14.77-14.77-32.65-22.16-53.62-22.16h-36.7c-31.45,0-58.14-11.2-80.06-33.6
                          c-21.92-22.4-32.88-49.32-32.88-80.78v-111.04c0-2.21-0.1-4.39-0.26-6.54v-66.68c0-52.74-18.91-97.77-56.71-135.11
                          c-37.81-37.33-83.09-56-135.82-56c-53.06,0-98.49,18.67-136.3,56c-37.81,37.34-56.71,82.37-56.71,135.11v190.15
                          c21.92,0,40.75-7.86,56.47-23.59c15.73-15.73,23.59-34.55,23.59-56.47v-110.09c0-31.45,10.96-58.54,32.88-81.26
                          c21.92-22.71,48.61-34.07,80.06-34.07c31.13,0,57.66,11.44,79.59,34.31s32.88,49.88,32.88,81.02v110.09
                          c0,2.21,0.1,4.39,0.26,6.54v67.63c0,52.74,18.98,97.62,56.95,134.63c37.96,37.02,83.32,55.52,136.06,55.52h112.47
                          C1229.16,1792.13,1221.77,1774.26,1207,1759.49z"/>
                      <circle cx="1141.59" cy="1590.68" r="43.77"/>
                  </g>
              </g>
              <g>
                  <text transform="matrix(1 0 0 1 1299.4673 1486.0029)"><tspan x="0" y="0" class="st0 st1">núcleoLegal</tspan><tspan x="0" y="120.86" class="st0 st2">ABOGADOS</tspan></text>
              </g>
          </g>
      </svg>
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



  def handle_event("delete", %{"id"=> id}, socket) do

    volunteer = Volunteers.get_volunteer!(id)

    { :ok, _ } = Volunteers.delete_volunteer(volunteer)

    socket = stream_delete(socket, :volunteers, volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id"=> id}, socket) do

    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer } = Volunteers.toggle_status_volunteer(volunteer)
        # as the volunteer already exists in the dom we this will update the volunteer and not just insert it
        # socket = stream_insert(socket,:volunteers, volunteer)
    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do

    socket =
      stream_insert(socket, :volunteers, volunteer, at: 0)
      |> update(:count, &(&1 + 1))

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = stream_insert(socket,:volunteers, volunteer)
    {:noreply, socket}
  end

end
