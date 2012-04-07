# -*- encoding : utf-8 -*-

#
#  == Define abilities for cancan
#
#  if  role admin
#    allow everything
#  else
#    if logged in
#      cancan methods for a logged in user
#      cancan methods for special roles
#    else
#      cancan for anyone (public)
#    end
#  end
#  
class Ability

  include CanCan::Ability

  # Called by cancan with the current_user or nil if
  # no user signed in. If so, we create a new user object which can be
  # identified as an anonymous user by calling new_record? on it.
  # if user.new_record? is true this means the session belongs to a not
  # signed in user.
  def initialize(user)
    user ||= User.new # guest user

    if user.role? :admin
      can :manage, :all
    else
      
      # Not Admin?, let's see ...
      unless user.new_record? # Any signed in user
        can [:read, :manage, :update_avatar, :crop_avatar], User do |usr|
          user == usr
        end

        can [:manage], UserNotification do |notification|
          notification.user == user
        end


        # Users with role
        if user.role?(:guest)
          can :read, [Page, Blog] do |resource|
            rc = if resource.respond_to? :is_draft
              resource.is_draft != true && resource.is_online?
            else
              true
            end
            authority = resource.is_a?(Blog) ? resource : resource.blog
            rc = false if authority.user_role && authority.user_role > user.roles_mask
            rc
          end
          can :create, Comment
        end
        
        if user.role?(:confirmed_user)
          can :create, Invitation
          can :manage, PolcoGroup
        end
        
        if user.role?(:author)
          can :create, [Page, Blog, Posting]
        end
        
        if user.role?(:moderator)
          can :manage, [Posting, Comment]
        end
        
        if user.role?(:maintainer)
          can :manage, [Page, Blog, Posting, Comment, UserNotification]
          can :details, User
        end

      end # Any signed in user

      # Anybody
      can :read, [Bill, PolcoGroup]
      can :read, Posting do |posting|
        access = (posting.is_draft != true) && posting.blog.public? && posting.recipient_ids.empty? && posting.is_online?
        unless (access == true || user.new_record?)
          access = posting.recipient_ids.include?(user.id)
        end
        access
      end
      
      can :read, [Page, Blog] do |resource|
        if resource.respond_to? :is_draft
          resource.is_draft != true
        else
          true
        end
      end
      can :create, Comment
      can :read, Comment do |comment|
        comment && !comment.new_record?
      end
      can :manage, Comment do |comment,session_comments|
        unless comment.new_record?
          # give 15mins to edit new comments
          expire = comment.updated_at+ENV['CONSTANTS_max_time_to_edit_new_comments'].to_i.minutes
          begin
            session_comments.detect { |c| c[0].eql?(comment.id.to_s) } &&  (Time.now < expire)
          rescue
            false
          end
        end
      end
    end # # not admin
  end # initialize

end # class