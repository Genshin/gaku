class AddressesController < ApplicationController

  inherit_resources

  actions :index, :show, :new, :create, :update, :edit, :destroy

  before_filter :load_student, :only => [:edit, :update]
  before_filter :load_address, :only => [:edit, :destroy]

  def edit
    super do |format|
      format.js {render 'edit'}  
    end  
  end

  def update
    super do |format|
      # Find student/show address row to update it
      format.js { render 'update' }  
    end  
  end

  def destroy
    #destroy! :flash => !request.xhr?
    @address.destroy  
    render :nothing => true
  end

  def make_primary
    @student = Student.find(params[:student_id])
    @address = Address.find(params[:id])
    @student_address = StudentAddress.find_by_student_id_and_address_id(@student.id,@address.id)
    @student_address.make_primary
    render :nothing => true
  end

  private

    def load_student
      @student = Student.find(params[:student_id])
    end

    def load_address
      @address = Address.find(params[:id])
    end
  
end