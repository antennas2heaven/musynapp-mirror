class FansController < ApplicationController

  load_resource
  authorize_resource except: :show

  def show
    continue_registration_or_show_user @fan
  end

  def edit
  end

  def update
    if @fan.update_attributes(fan_params)
      proceed_registration || redirect_to(@fan)
    else
      flash.now[:error] = @fan.errors.messages.map{ |key,val| "#{key} #{val}\n" } 
      render( current_user.current_step || params[:form_id] )
    end
  end


  private


  def fan_params
     params.require(:fan).permit(:avatar, favorite_band_ids: [],
                                  favorite_venue_ids: [],
                                  friend_ids: [])
  end

end
