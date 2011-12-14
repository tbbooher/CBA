class LegislatorsController < ApplicationController
  # GET /legislators
  # GET /legislators.xml
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction

  def index
    #.order(sort_column + " " + sort_direction)
    # added by nate
    @legislators = Legislator.legislator_search(params[:legislator_search]).page(params[:page]).per(10)
    # added by nate
    @bills = Bill.bill_search(params[:bill_search]).page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @legislators }
    end
  end

  # GET /legislators/1
  # GET /legislators/1.xml
  def show
    @legislator = Legislator.find(params[:id])
    unless @legislator.is_senator?
      @polco_group = @legislator.members_district
      @district = true
    else
      @polco_group = @legislator.members_state_group
    end

    @title = "112th Congress: #{@polco_group.name} &mdash; #{@legislator.full_title}"

    @bills = (Bill.all.to_a - Bill.introduced_house_bills).page(params[:page]).per(20)

    @members   = @polco_group.members.page(params[:page]).per(10)
    @followers = @polco_group.followers.page(params[:page]).per(10)

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @legislator }
    end
  end

  # GET /legislators/new
  # GET /legislators/new.xml
  def new
    @legislator = Legislator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @legislator }
    end
  end

  # GET /legislators/1/edit
  def edit
    @legislator = Legislator.find(params[:id])
  end

  # POST /legislators
  # POST /legislators.xml
  def create
    @legislator = Legislator.new(params[:legislator])

    respond_to do |format|
      if @legislator.save
        format.html { redirect_to(@legislator, :notice => 'Legislator was successfully created.') }
        format.xml  { render :xml => @legislator, :status => :created, :location => @legislator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @legislator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /legislators/1
  # PUT /legislators/1.xml
  def update
    @legislator = Legislator.find(params[:id])

    respond_to do |format|
      if @legislator.update_attributes(params[:legislator])
        format.html { redirect_to(@legislator, :notice => 'Legislator was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @legislator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /legislators/1
  # DELETE /legislators/1.xml
  def destroy
    @legislator = Legislator.find(params[:id])
    @legislator.destroy

    respond_to do |format|
      format.html { redirect_to(legislators_url) }
      format.xml  { head :ok }
    end
  end

  private

  # added by nate
  def sort_column
    params[:sort] || "district"
  end

  # added by nate
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
