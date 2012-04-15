class SecondaryEffectsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :update, :new, :edit]

  def index                          
    @se = Medication.secondary_effects
    respond_to do |format|
      format.html {}
      format.json { render json: @se.map {|se|  
       if (params[:term].present? && se.downcase.include?(params[:term].downcase))  then        
         {'id'=> se.downcase, 'label'=> se, 'value'=> se}     
         end  
      }.compact.sort_by { |my_item| my_item[:id] }}
    end
  end

  def create
    @medication = Medication.find_by_slug(params[:medication_id])
  end

  def new
    @medication = Medication.find_by_slug(params[:medication_id])
    @prescription = @medication.prescriptions.build
  end

end
