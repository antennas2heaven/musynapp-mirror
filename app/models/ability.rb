class Ability
  include CanCan::Ability

  def can_take_step step, registrateable_class
    can step.to_sym, registrateable_class do |obj|
      (!obj.registration.pending? || obj.registration.current_step == step) &&
      obj.id == @user.registrateable_id
    end
  end

  def initialize(user)
    @user = user || Registration.new
    registrateable = @user.registrateable
    alias_action :create, :read, :update, :destroy, :to => :crud

    can [:read], Show
    can [:find, :read], Venue
    can [:find, :read], Band

    if @user.persisted?
      can :logout, Registration
      can :request_address, Show do |show|
          show.private &&
         !show.address_exposed_for?(@user) &&
         !show.band.virtual
      end
      can :show_address, Show do |show|
        !show.private ||
         show.address_exposed_for?(@user)
      end
      can :send_message, Registration do |another_user|
        another_user != @user and 
        [another_user, @user].all? { |u| u.registrateable_type != 'Fan' }
      end
    else
      can [:login_form, :login, :new, :create], Registration
    end

    case registrateable
      when Fan
        can :manage, Fan, id: registrateable.id
      when Band
        can [:edit, :update], Band, id: registrateable.id
        can_take_step 'edit_media', Band
      when Venue
        can [:edit, :update], Venue, id: registrateable.id
        can_take_step 'edit_media', Venue
        can_take_step 'add_show', Venue
    end

    if @user.is?('Venue') || @user.is?('Band')
      can [:new, :create], Show, id: @user.id
      can :crud, Show, venue_id: registrateable.id
      can :crud, Show, band_id: registrateable.id
      can [:index, :accept, :reject, :manage_selection], Request do |req_obj|
        (req_obj.requester == registrateable) || (req_obj.requested == registrateable)
      end
    end

    can :skip, Registration

  end
end
