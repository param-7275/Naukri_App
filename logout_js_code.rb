<style type="text/css">
  #ReminderEmail .tab-pane.fade{
    display: none;
  }
  #ReminderEmail .tab-pane.fade.active.in{
    display: block;
  }
  #ReminderEmail .modal-body{
    min-height: 330px;
  }
</style>
<div id= "myheader">

<nav class="navbar navbar-inverse">
  <div class="header-main">
    <div class="navbar-header">

      <% if user_signed_in?%>
          <% if current_user.role_as_admin? || current_user.role?("Super-Admin") %>
               <a class="navbar-brand" href="/admin/home"><img src="/assets/logo.png" alt="Logo"></a>
           <%else%>
                 <a class="navbar-brand" href="/userHome"><img src="/assets/logo.png" alt="Logo" ></a>
          <%end%>
      <%else%>
      <a class="navbar-brand" href="/"><img src="/assets/logo.png" alt="Logo"></a>
      <%end%>
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
        <i class="fa fa-bars"></i>
      </button>
    </div>
    <div class="collapse navbar-collapse" id="myNavbar">
      <ul class="nav navbar-nav">
        <% if user_signed_in? %>
            <% if current_user.user_role? %>
              <li>
                <span class="send_reminder">
                    <a href="javascript:" class="btn reminder_modal_btn bg-pink" data-toggle="modal" data-target="#ReminderEmail">Send Reminder</a>
                </span>

              </li>
            <%end%>
        <%end%>
        <% unless user_signed_in? %>

               <li class="<% if request.fullpath == "/"%> active <%end%>">
                    <%= link_to "Home", root_path,class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase" %>

            </li>

             <!--  <li class="<% if request.fullpath == "/about"%> active <% end %>">
          <a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase" href="/about">About US</a>
        </li>-->

             <!--  <li class="<% if request.fullpath == "/faq"%> active <% end %>">
             <%= link_to "FAQs", faq_path,class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase"%>
              </li>-->

              <% if !user_signed_in? %><li <% if current_page?(root_path) %> class="active" <% end %>>
          <!--<a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase download-app" <% if current_page?(root_path) %> href="#downloadapp" <% else %> href="<%= root_path %>#downloadapp" <%end %>>Download our App</a>-->
        </li><% end %>

               <li class="<% if request.fullpath == "/users/sign_in"%> active <% end %>">
          <a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase btn btn-default f-w-600" href="/users/sign_in">Sign in</a></li>


        <% else %>  <!-- signed in user -->
            <% unless (current_user.role_as_admin? || current_user.role?("Super-Admin")) %>

                 <li class="<% if request.fullpath == "/userHome" || request.fullpath == "/"%> active <% end %>">
              <%= link_to('Home',user_home_path, class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase") %>
              </li>
              <%if current_user.nominable_schools.present? && current_user.is_nominator == true%>
                 <li class="<% if request.fullpath == "/invites/new" %> active <% end %>">
                <%= link_to('Invite',new_invite_path, class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase") %>
                </li>
              <% end %>
              <!--<li class="<% if request.fullpath == "/about"%> active <% end %>">
              <a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase" href="/about">About US</a></li>-->
              <%end%>


                  <!-- <li class="<% if request.fullpath == "/faq"%> active <% end %>">
                <%= link_to('FAQs',faq_path, class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase") %></li>-->

                 <% if !user_signed_in? %><li <% if current_page?(root_path) %> class="active" <% end %>>
                <a <% if current_page?(root_path) %> href="#downloadapp" <% else %> href="<%= root_path %>#downloadapp" <%end %> class= "f-s-16 l-s-2 text-center l-h-30 tt-uppercase download-app">Download Our App</a></li><% end %>

         <% unless (current_user.role_as_admin? || current_user.role?("Super-Admin")) %>


               <li class="<% if request.fullpath == "/posts"%> active <% end %>">
            <%= link_to("MY POSTS", posts_path,class: "f-s-16 l-s-2 text-center l-h-30 tt-uppercase")%>
          </li>

         <%end%>

          <% if current_user.is_verifier? %>

                 <li class="<% if params[:action] == "existingJoinRequest"%> active <% end %>">
              <a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase" href="/schools/existingJoinRequest?id=<%=current_user.my_schools.try(:first).try(:id)%>">VERIFIER
                <% if join_request_count > 0 %>
                <span class="badge verifier_notification"><%= join_request_count %></span>
                <%end%>
              </a></li>
           <%end%>
          <li class="hidden-xs hidden-sm notification"><div class="dropdown">
            <a class="f-s-16 l-s-2 text-center l-h-30 tt-uppercase dropdown-toggle" data-toggle="dropdown" href="javascript:;"><img src="/assets/bell.png" style="max-width: 20px;" alt="Bell">

            <% if current_user.role?("Super-Admin") %>
              <% if super_admin_notification.count > 0 %>
               <span class="badge"><%= super_admin_notification_count   %></span>
               <%end%>
            <% elsif (current_user.role_as_admin?)  %>

                  <%if admin_notification_count > 0 %>
                    <span class="badge"><%= admin_notification_count %></span>
                 <%end%>

            <%else%>

               <% unless current_user.drafted_posts.count.zero? %>
                <span class="badge"><%= current_user.drafted_posts.count %></span>
                <%end%>

            <%end%>
          </a>
            <ul class="dropdown-menu">
            <% if current_user.role?("Super-Admin") %>
              <% super_admin_notification_print.each do |message| %>
               <%= message.try(:html_safe) %>
              <%end%>
            <%else%>
              <%= active_drafted_post_count_notification.try(:html_safe)%>
            <%end%>
            </ul>

          <li class="visible-xs visible-sm">
            <a class="f-s-16 l-s-2 text-center l-h-30" href="javascript:;" data-toggle="collapse" data-target="#setting"><%= "#{current_user.first_name.capitalize}"%> <i class="fa fa-angle-down"></i></a>
            <div id="setting" class="collapse">
              <ul>
                <% if current_user.role?("Super-Admin") && current_user&.location_types&.pluck(:name).include?('UK') %>
                  <% School.where(subdomain: 'hurlingham').each do |sub_school|%>
                    <li>
                      <% if @school.present? && @school = sub_school %>
                        <%= link_to("Back to Admin Panel", back_to_admin_panel_path(sub_school.id), method: :post, class: "")%>
                      <% else %>
                        <%= link_to("Switch to #{sub_school.subdomain.capitalize}", switch_to_school_path(sub_school.id), method: :post, class: "")%>
                      <% end %>
                    </li>
                  <% end %>
                <% end %>
              <li><a href="/setting">Settings</a></li>
              <li><%= link_to('Sign Out', destroy_user_session_path, method: :delete) %></li>
            </ul>
          </div>
          </li>
          <li class="hidden-xs hidden-sm"><div class="dropdown">
            <a class="f-s-16 l-s-2 text-center l-h-30  dropdown-toggle" data-toggle="dropdown">
              <% if current_user.role?("Super-Admin") %>
              <%= "Super Admin, #{current_user.first_name.capitalize}"%>
              <% elsif current_user.role_as_admin? %>
              <%= "Admin, #{current_user.first_name.capitalize}"%>
              <%else%>
              <%= "#{current_user.first_name.capitalize}"%>
              <%end%>
          <i class="fa fa-angle-down"></i></a>
            <ul class="dropdown-menu">
              <% if current_user.role?("Super-Admin") && current_user&.location_types&.pluck(:name).include?('UK') %>
                  <% School.where(subdomain: 'hurlingham').each do |sub_school|%>
                    <li>
                      <% if @school.present? && @school = sub_school %>
                        <%= link_to("Back to Admin Panel", back_to_admin_panel_path(sub_school.id), method: :post, class: "")%>
                      <% else %>
                        <%= link_to("Switch to #{sub_school.subdomain.capitalize}", switch_to_school_path(sub_school.id), method: :post, class: "")%>
                      <% end %>
                    </li>
                  <% end %>
                <% end %>
              <li><a href="/setting" data-turbolinks = "false">Settings</a></li>
              <li><%= link_to('Sign Out', destroy_user_session_path, method: :delete) %></li>
            </ul>
          </div>
        </li>
        </ul>
        <% end %>
         </nav>
        </div>

</div>
</div>
  <% if user_signed_in? %>
      <div id="ReminderEmail" class="modal fade" role="dialog" tabindex="-1" role="dialog" aria-labelledby="modalLabel" aria-hidden="true" data-backdrop="static", data-keyboard="false">
         <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content clearfix">
               <div class="modal-header">
                  <div class="titleAccorn text-center">
                     <h3>Select Pinboards</h3>
                  </div>
               </div>
               <% if @user_locations.size > 1 %>
               <ul class="nav nav-tabs nav-justified">
                 <% @user_locations.each_with_index do |location, index| %>

                      <li class="<% if index == 0 %> active <% end %>"><a data-toggle="tab" href="#<%=location.location_type.name%>-reminder-tab"><%=location.location_type.name%></a></li>

                  <% end %>
                </ul>
                <% end %>
               <div class="modal-body clearfix">
                  <div class="col-md-12 col-xs-12 col-sm-6 no-padding">
                     <input type="hidden" name="post-id" required id="post_id">
                    <% @user_locations.each_with_index do |location, index| %>
                      <div id="<%=location.location_type.name %>-reminder-tab" class="tab-pane fade in <% if index == 0 %> active <% end %>">
                        <% if current_user.as_admin_role_schools.where(location_type_id: location.location_type_id).present? %>
                           <div class="checkbox m-0" style="margin: 0px;">
                              <label class="custom-checkbox">
                              <input type="checkbox" name="all" required id="ckbCheckAllEmail" class="ckbCheckAllEmail">All
                              <span class="checkmark"></span>
                              </label>
                                <% current_user.as_admin_role_schools.where(location_type_id: location.location_type_id).order("name asc").each do |school| %>
                                  <label class="custom-checkbox">
                                  <input type="checkbox" name="junior" required value="<%=school.id%>" class="checkBoxClassEmail"><%= school.name %>
                                  <span class="checkmark"></span>
                                  </label>
                                <% end %>
                           </div>
                         <% else %>
                          <div class="text-center f-s-16"> No Pinboard to select </div>
                         <% end %>
                      </div>
                    <% end %>
                  </div>
               </div>
               <div class="modal-footer clearfix">
                  <button type="button" class="btn btn-default m-l-0 bg-green email_cancel_btn" data-dismiss="modal">Cancel</button>
                  <button type="button" class="btn btn-default bg-pink reminder_btn">Send</button>
               </div>
            </div>
         </div>
      </div>
  <%end%>
<script type="text/javascript">
      $(".reminder_btn").click(function(){
      var school_ids = []
          $(".checkBoxClassEmail").each(function(index,element){
            if ($(this).prop('checked') == true)
            school_ids.push($(element).val())
          })
          if (school_ids.length != 0 )
          {
            $('.parent-loader').removeClass('hidden');
            $.ajax({
                            url: "<%= reminder_common_index_path %>",
                            type: "POST",
                            data: {
                              school_ids: school_ids,
                              authenticity_token: $("meta[name='csrf-token']").attr("content")
                              },
                            success: function(success){
                                location.reload();
                               $('.parent-loader').removeClass('hidden');
                            },
                            error: function(error){
                              $('.parent-loader').removeClass('hidden');
                              location.reload();
                            }
                    });
          }


      });

        $(".ckbCheckAllEmail").click(function () {
   $(this).parents('.tab-pane.active').find(".checkBoxClassEmail").prop('checked', $(this).prop('checked'));
   });


      $(".email_cancel_btn").click(function(){
        $(".checkBoxClassEmail, .ckbCheckAllEmail").prop("checked", false);
      });


</script>