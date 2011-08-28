class BillsController < ApplicationController
  load_and_authorize_resource

  # GET /bills
  # GET /bills.xml
  def index
    #@bills = Bill.page(1).per(10)
    @bills = Bill.all.paginate(:page => params[:page],
       :per_page => APPLICATION_CONFIG[:pages_per_page] || 5
    )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bills }
    end
  end

  def vote_on_bill
    #bill = Bill.find(params[:id])
    current_user.vote_on(@bill, params[:value].to_sym)
    # need redirect
    redirect_to(@bill)
  end

  # GET /bills/1
  # GET /bills/1.xml
  def show
    #@bill = Bill.find(params[:id])
    @user = current_user

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/new
  # GET /bills/new.xml
  def new
    #@bill = Bill.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bill }
    end
  end

  # GET /bills/1/edit
  def edit
    #@bill = Bill.find(params[:id])
  end

  # POST /bills
  # POST /bills.xml
  def create
    #@bill = Bill.new(params[:bill])

    respond_to do |format|
      if @bill.save
        format.html { redirect_to(@bill, :notice => 'Bill was successfully created.') }
        format.xml  { render :xml => @bill, :status => :created, :location => @bill }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bills/1
  # PUT /bills/1.xml
  def update
    #@bill = Bill.find(params[:id])

    respond_to do |format|
      if @bill.update_attributes(params[:bill])
        format.html { redirect_to(@bill, :notice => 'Bill was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bill.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.xml
  def destroy
    #@bill = Bill.find(params[:id])
    @bill.destroy

    respond_to do |format|
      format.html { redirect_to(bills_url) }
      format.xml  { head :ok }
    end
  end

  def house_bills
    @bills = Bill.house_bills.paginate(:page => params[:page],
       :per_page => 20
    )
    @user = current_user
    if params[:id]
      @bill = Bill.find(params[:id])
    else
      @bill = Bill.first
    end
    @legislator = @bill.sponsor
  end

  def senate_bills
    @bills = Bill.senate_bills
  end

  def process_page
    user = current_user
    bill = Bill.find(params[:bill_id])
    # error checking here
    case params[:vote]
      when "For"
        vote = :aye
      when "Against"
        vote = :nay
      when "Abstain"
        vote = :abstain
      when "Present"
        vote = :present
    end
    comment = Comment.new
    comment.comment = params[:comment]
    comment.name = user.name
    comment.email = user.email
    bill.comments << comment # need markup stuff . . .
    user.vote_on(bill, vote)
    bill.save! # <-- the key line
    redirect_to house_bills_page_path(bill.id)
  end
end
