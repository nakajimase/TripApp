class ArticleController < ApplicationController

def hello
#    render :text => 'Hello!'
 # end
#def index
    personal = {'name' => 'Yamada', 'old' => 28}

    render :json => personal
  end
end
