class SecondaryEffectsController < ApplicationController
  def index                          
    @se = Medication.secondary_effects
    respond_to do |format|
      format.html            
      format.json { render json: @se.map {|se|  
       if (params[:term].present? && se.downcase.include?(params[:term].downcase))  then        
         {'id'=> se.downcase, 'label'=> se, 'value'=> se}     
         end  
      }.compact.sort_by { |my_item| my_item[:id] }}
    end
  end
end
