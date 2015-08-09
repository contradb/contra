module GloboHelper
  def administrator?() 
    current_user && (1 == current_user.id)
  end

  def view_icon_html()
    '<span class="glyphicon glyphicon-list" aria-label="view"  aria-label="view" data-toggle="tooltip" data-placement="left" title="view">'.html_safe
  end
  def edit_icon_html()
    '<span class="glyphicon glyphicon-edit" aria-label="edit"  aria-label="edit" data-toggle="tooltip" data-placement="left" title="edit">'.html_safe
  end
  def delete_icon_html()
    '<span class="glyphicon glyphicon-trash" aria-label="delete" data-toggle="tooltip" data-placement="left" title="delete">'.html_safe
  end
  def new_icon_html()
    "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span>".html_safe
  end



  def new_dance_button_html(choreographer_id: nil)
    link_to '<span>'.html_safe + new_icon_html() + ' New Dance</span>'.html_safe, 
            new_dance_path({choreographer_id: choreographer_id}), {class: "btn btn-default btn-md", type: "button"}
  end
  def new_choreographer_button_html()
    link_to '<span>'.html_safe + new_icon_html() + ' New Choreographer</span>'.html_safe, 
            new_choreographer_path, {class: "btn btn-default btn-md", type: "button"}
  end

end
