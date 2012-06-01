class MedicationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :new]
  before_filter :authenticate_admin, :only => [:list, :edit, :update, :destroy]
  before_filter :get_medication_and_facets, :only => [:show, :map]
  # GET /medications
  # GET /medications.json
  def index
    @home_page = true
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @medications }
    end
  end

  # GET /medications/search
  def elastic_search             
    @search = params[:q]
    @medications = Medication.elastic_search params        

    @facets      =  @medications.facets['secondary_effects']["terms"]
    respond_to do |format|
       format.html 
       format.json { render json: @medications }
     end
  end
     
  def search
    @medications = Medication.where(:name => params[:q])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @medications }
    end
  end


  # GET /medications/1
  # GET /medications/1.json
  def show
    @prescriptions = @medication.prescriptions.order_by([:created_at, :desc]).page(params[:page]).per(10)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @medication }
    end
  end

  def map
  end

  # GET /medications/new
  # GET /medications/new.json
  def new
    @medication = Medication.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @medication }
    end
  end

  # POST /medications
  # POST /medications.json
  def create
    @medication = Medication.new(params[:medication].merge(user_agent: request.user_agent))
    @medication.user = current_user

    respond_to do |format|
      if @medication.save
        format.html { redirect_to @medication, notice: t("medications.flash.success") }
        format.json { render json: @medication, status: :created, location: @medication }
      else
        format.html { render action: "new" }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  ## ADMIN PART ## 

  # GET /medications/1/edit
  def edit
    @medication = Medication.find_by_slug(params[:id])
  end

  # PUT /medications/1
  # PUT /medications/1.json
  def update
    @medication = Medication.find_by_slug(params[:id])

    respond_to do |format|
      if @medication.update_attributes(params[:medication])
        format.html { redirect_to @medication, notice: 'Medication was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /medications/1
  # DELETE /medications/1.json
  def destroy
    @medication = Medication.find_by_slug(params[:id])
    @medication.destroy

    respond_to do |format|
      format.html { redirect_to medications_url }
      format.json { head :ok }
    end
  end

  def list
    @medications = Medication.page(params[:page]).per(10)
  end


private
  def get_medication_and_facets
    @medication = Medication.find_by_slug(params[:id])
    @prescriptions = Prescription.elastic_search @medication, params                   
    @facets = @prescriptions.facets['secondary_effects']["terms"]
  end

end
