class MedicationsController < ApplicationController
  # GET /medications
  # GET /medications.json
  def index
    @medications = Medication.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @medications }
    end
  end

    # GET /medications/search
  def elastic_search             
    q = params[:q].present? ? params[:q] : "*"
    t = params[:terms].present? ? params[:terms].split(',')  : []
    @medications = Medication.tire.search do                    
        if t!=[] 
          filter :terms, :secondary_effects => t 
        end
        query { string q }
        facet('secondary_effects') { terms :secondary_effects , :global => false}
    end

    @facets = _prepare_facets @medications, t             
     
    respond_to do |format|
       format.html 
       format.json { render json: @medications }
     end
  end
     
  def _prepare_facets (meds, t)

    meds.facets['secondary_effects']["terms"].map!{|facet|      
        facet['selected'] = t.include?(facet['term'])
        facet['remove_facet'] = (t - [facet["term"]])  * ","
        facet['add_facet'] = (t + [facet["term"]]) * ","
        facet
      } 
  end

     
  def search
    @medications = Medication.search(params[:q])
        
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @medications }
    end
  end


  # GET /medications/1
  # GET /medications/1.json
  def show
    @medication = Medication.find_by_slug(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @medication }
    end
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

  # GET /medications/1/edit
  def edit
    @medication = Medication.find_by_slug(params[:id])
  end

  # POST /medications
  # POST /medications.json
  def create
    @medication = Medication.new(params[:medication])

    respond_to do |format|
      if @medication.save
        format.html { redirect_to @medication, notice: 'Medication was successfully created.' }
        format.json { render json: @medication, status: :created, location: @medication }
      else
        format.html { render action: "new" }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
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
end
