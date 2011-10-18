class PolcoGroupsController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction

  # GET /polco_groups
  # GET /polco_groups.xml
  def index
    #@polco_groups = PolcoGroup.all.paginate(:page => params[:page], :per_page =>  20) # where(name: /#{params[:q]}/i)
    @groups = Hash.new
    @groups[:states] = PolcoGroup.states.all.paginate(:page => params[:page], :per_page =>  20)
    @groups[:districts] = PolcoGroup.districts.all.paginate(:page => params[:page], :per_page =>  20)
    @groups[:customs] = PolcoGroup.customs.all.paginate(:page => params[:page], :per_page =>  20)

    respond_to do |format|
      format.html # index.haml
      format.xml { render :xml => @polco_groups }
      format.json { render :json => @polco_groups.map{|g| {:id => g.id, :name => g.name}} }
    end
  end

  # for the auto-group work
  def custom_groups

    groups_list = prep_format(PolcoGroup.where(name: /#{params[:q]}/i, type: :custom))

    respond_to do |format|
      format.json {render :json => groups_list}
    end
  end

  def state_groups

    groups_list = prep_format(PolcoGroup.where(name: /#{params[:q]}/i, type: :state))

    respond_to do |format|
      format.json {render :json => groups_list}
    end
  end

  def district_groups

    groups_list = prep_format(PolcoGroup.where(name: /#{params[:q]}/i, type: :district))

    respond_to do |format|
      format.json {render :json => groups_list}
    end
  end

  def manage_groups
    @user = current_user
    # TODO - this should be optimized for Mongoid
    @joined_groups_json_data = @user.joined_groups.select{|s| s.type == :custom}.map{|g| {:id => g.id, :name => g.name}}.to_json
    @followed_groups_states = @user.followed_groups.select{|s| s.type == :state}.map{|g| {:id => g.id, :name => g.name}}.to_json
    @followed_groups_districts = @user.followed_groups.select{|s| s.type == :district}.map{|g| {:id => g.id, :name => g.name}}.to_json
    @followed_groups_custom = @user.followed_groups.select{|s| s.type == :custom}.map{|g| {:id => g.id, :name => g.name}}.to_json
    @custom_groups = PolcoGroup.customs
  end

  def update_groups
    @user = current_user
    # TODO -- need some logic here to ensure they don't leave the default groups
    joined_groups = params[:joined_groups].split(",")
    followed_groups =  (params[:followed_groups_states].split(",") +
        params[:followed_groups_districts].split(",") +
        params[:followed_groups_custom].split(",")).uniq
    #all_groups = joined_groups.merge(followed_groups)
    @user.joined_group_ids = joined_groups
    @user.followed_group_ids = followed_groups
    #@user.update_member_count
    respond_to do |format|
      if @user.save
        format.html { redirect_to manage_groups_path, :notice => "Success" }
      else
        format.html { redirect_to(manage_groups_url, :notice => "Error!") }
      end
    end
  end

  # GET /polco_groups/1
  # GET /polco_groups/1.xml
  def show
    @bills = @polco_group.get_bills
    @members = @polco_group.members
    @followers = @polco_group.followers

    respond_to do |format|
      format.html # show.haml
      format.xml { render :xml => @polco_group }
    end
  end

  # GET /polco_groups/new
  # GET /polco_groups/new.xml
  def new
    @polco_group = PolcoGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @polco_group }
    end
  end

  # GET /polco_groups/1/edit
  def edit
    @polco_group = PolcoGroup.find(params[:id])
  end

  # POST /polco_groups
  # POST /polco_groups.xml
  def create
    # TODO -- might not be needed -- load or authorize
    @polco_group = PolcoGroup.new(params[:polco_group])
    @polco_group.title = "#{params[:polco_group][:name]}_custom"

    respond_to do |format|
      if @polco_group.save
        format.html { redirect_to(@polco_group, :notice => 'PolcoGroup was successfully created.') }
        format.xml { render :xml => @polco_group, :status => :created, :location => @polco_group }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @polco_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /polco_groups/1
  # PUT /polco_groups/1.xml
  def update
    @polco_group = PolcoGroup.find(params[:id])
    @polco_group.title = "#{params[:polco_group][:name]}_custom"   

    respond_to do |format|
      if @polco_group.update_attributes(params[:group])
        format.html { redirect_to(@polco_group, :notice => 'PolcoGroup was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @polco_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /polco_groups/1
  # DELETE /polco_groups/1.xml
  def destroy
    @polco_group = PolcoGroup.find(params[:id])
    @polco_group.destroy

    respond_to do |format|
      format.html { redirect_to(polco_groups_url) }
      format.xml { head :ok }
    end
  end

  def districts_and_reps
    @legislators = Legislator.legislator_search(params[:legislator_search]).paginate(:page => params[:page], :per_page =>  10)
    @bills = Bill.bill_search(params[:bill_search]).paginate(:page => params[:page], :per_page => 10)
  end

  def states_and_senators
    @states = PolcoGroup.states.paginate(:page => params[:page], :per_page =>  10)
    #Legislator.senators.paginate(:page => params[:page], :per_page =>  10)
    @bills = Bill.senate_bills.paginate(:page => params[:page], :per_page => 10)
  end

  private

  def prep_format(list)
    # to json
    list.map{|g| {:id => g.id, :name => g.name}}
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
