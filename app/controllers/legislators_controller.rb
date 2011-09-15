class LegislatorsController < ApplicationController
  # GET /legislators
  # GET /legislators.xml
  helper_method :sort_column, :sort_direction

  def index
    #@legislators = Legislator.all.paginate(:page => params[:page], :per_page =>  20)
    @legislators = Legislator.all.order(sort_column + " " + sort_direction)
    @bills = Bill.all.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @legislators }
    end
  end

  # GET /legislators/1
  # GET /legislators/1.xml
  def show
    @legislator = Legislator.find(params[:id])
    @bills = Bill.all.paginate(:page => params[:page], :per_page => 20)
    @users = User.all.paginate(:page => params[:page], :per_page => 10)

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

  def sort_column
    params[:sort] || "district"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
