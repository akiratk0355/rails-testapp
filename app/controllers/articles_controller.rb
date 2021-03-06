class ArticlesController < ApplicationController
  
  load_and_authorize_resource
  
  def index
    @searched = false
    if params[:search]
      @searched = true
      @articles = Article.search(params[:search])
    else
      @articles = Article.all
    end
    
    unless current_user.can_admin?
      @articles = @articles.where("published = true OR user_id = ?", current_user.id)
    end
    
    @articles = @articles.order(published_at: :desc).includes(:user)
  end
  
  def show
    @article = Article.find(params[:id])
  end
  
  def new
    @article = Article.new
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def create
    #render plain: params[:article].inspect
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to articles_path
    else
      redirect_to new_article_path, :flash => { :error => @article.errors.full_messages.join(', ') }
    end
  end
  
  def update
    @article = Article.find(params[:id])
    
    if @article.update(article_params) # invokes validation
      redirect_to @article
    else
      redirect_to edit_article_path, :flash => { :error => @article.errors.full_messages.join(', ') }
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    
    redirect_to articles_path
  end
  
  private
  def article_params
    params.require(:article).permit(:title, :text, :published)
  end
end
