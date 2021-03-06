class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @stories = Story.find(:all, :include => :node, :conditions => {:nodes => {:parent_node => 0}})
  end

  def new
    @parent_node = params[:id] if params[:id]
    @story = Story.new
    @story.build_node
  end

  def show 
   @story = Story.find(params[:id])
  end

  def create
    story_params = {}
    process_upload
    story_params[:title] = node_params[:title]
    @story = Story.new(story_params)
    @story.user = current_user
    create_nodes
    @story.tag_list = params[:story][:tag_list]
    if @story.save
      redirect_to story_path(@story), :notice => "#{@story.title} was created successfully."
    else
      render :new, :alert => "Story could not be saved. Please see the errors below."
    end
  end

  def destroy
    story = Story.find(params[:id])
    story.destroy
    redirect_to stories_path, :notice => "Story removed successfully."
  end

  private

  def node_params
    params.require(:node).permit(:title, :content, :parent_node)
  end
end
