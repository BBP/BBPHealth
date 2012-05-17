class SecondaryEffectsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :update, :new, :edit]
  before_filter :find_medication, :only => [:create, :new]
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
    if params[:known_effects]
      fx = (params[:prescription][:secondary_effects].split(',') + params[:known_effects]).flatten.uniq.join(',')
      params[:prescription][:secondary_effects] = fx
    end
    @prescription = @medication.prescriptions.build(params[:prescription].merge(user_agent: request.user_agent, user: current_user))

    respond_to do |format|
      if @prescription.save
        format.html { redirect_to @medication, notice: t("medications.flash.success") }
        format.json { render json: @prescription, status: :created, location: @prescription }
      else
        format.html { render action: "new" }
        format.json { render json: @prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @prescription = @medication.prescriptions.build
  end

protected

  def find_medication
     @medication = Medication.find_by_slug(params[:medication_id])
     @prescriptions = Prescription.elastic_search @medication, params                   
     @facets = @prescriptions.facets['secondary_effects']["terms"]
  end

end
