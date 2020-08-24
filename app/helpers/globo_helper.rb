module GloboHelper
  def view_icon_html()
    '<span class="glyphicon glyphicon-list" aria-label="view" data-toggle="tooltip" data-placement="left" title="view"></span>'.html_safe
  end
  def edit_icon_html()
    '<span class="glyphicon glyphicon-edit" aria-label="edit" data-toggle="tooltip" data-placement="left" title="edit"></span>'.html_safe
  end
  def copy_icon_html()
    '<span class="glyphicon glyphicon-duplicate" aria-label="copy" data-toggle="tooltip" data-placement="left" title="copy"></span>'.html_safe
  end
  def delete_icon_html()
    '<span class="glyphicon glyphicon-trash" aria-label="delete" data-toggle="tooltip" data-placement="left" title="delete"></span>'.html_safe
  end
  def new_icon_html()
    "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span>".html_safe
  end
  def plus_icon_html() new_icon_html end
  def x_icon_html()
    "<span class='glyphicon glyphicon-remove' aria-hidden='true'></span>".html_safe
  end
  def rotate_icon_html()
    "<span class='glyphicon glyphicon-retweet' aria-hidden='true'></span>".html_safe
  end
  def save_icon_html()
    "<span class='glyphicon glyphicon-check' aria-hidden='true'></span>".html_safe
  end


  BUTTON_HTML_ATTR = {class: "btn btn-default btn-md contra-btn-midpage", type: "button"}.freeze

  def new_dance_button_html(choreographer_id: nil, label: "New Dance")
    link_to(content_tag(:span, new_icon_html() + ' ' + label),
            new_dance_path({choreographer_id: choreographer_id}),
            BUTTON_HTML_ATTR)
  end
  def new_dance_button_green_html(choreographer_id: nil, label: "New Dance")
    link_to(content_tag(:span, new_icon_html() + ' ' + label),
            new_dance_path({choreographer_id: choreographer_id}),
            {class: "btn btn-default btn-md btn-success contra-btn-midpage", type: "button"})
  end
  def new_dance_button_titlebar_html(choreographer_id: nil, label: "New Dance")
    content_tag(:p, class: 'navbar-btn') {
      link_to(content_tag(:span, new_icon_html() + ' ' + label),
              new_dance_path({choreographer_id: choreographer_id}),
              class: "btn btn-default", type: "button")
    }
  end
  def edit_dance_button_html(dance, label: "Edit Dance")
    link_to(content_tag( :span, edit_icon_html() + ' ' + label ),
            edit_dance_path(dance),
            BUTTON_HTML_ATTR)
  end
  def delete_dance_button_html(dance, label: "Delete Dance")
    link_to(content_tag( :span, delete_icon_html() + ' ' + label ),
            dance,
            BUTTON_HTML_ATTR.merge({method: :delete, data: { confirm: "Delete '#{dance.title}?'" }}))
  end
  def copy_dance_button_html(dance, label: "Copy Dance")
    link_to(content_tag( :span, copy_icon_html() + ' ' + label ),
            new_dance_path(copy_dance_id: dance),
            BUTTON_HTML_ATTR)
  end
  def new_choreographer_button_html(label: "New Choreographer")
    link_to(content_tag(:span, new_icon_html() + ' ' + label),
            new_choreographer_path,
            BUTTON_HTML_ATTR)
  end

  def new_program_button_html(label: "New Program")
    link_to(content_tag(:span, new_icon_html() + ' ' + label),
            new_program_path,
            BUTTON_HTML_ATTR)
  end
  def edit_program_button_html(program, label: "Edit Program")
    link_to(content_tag( :span, edit_icon_html() + ' ' + label ),
            edit_program_path(program),
            BUTTON_HTML_ATTR)
  end
  def delete_program_button_html(program, label: "Delete Program")
    link_to(content_tag( :span, delete_icon_html() + ' ' + label ),
            program,
            BUTTON_HTML_ATTR.merge({method: :delete, data: { confirm: "Delete '#{program.title}?'" }}))
  end
  def copy_program_button_html(program, label: "Copy Program")
    link_to(content_tag( :span, copy_icon_html() + ' ' + label ),
            new_program_path(copy_program_id: program),
            BUTTON_HTML_ATTR)
  end

  def edit_choreographer_button_html(choreographer, label: "Edit Choreographer")
    link_to(content_tag( :span, edit_icon_html() + ' ' + label ),
            edit_choreographer_path(choreographer),
            BUTTON_HTML_ATTR)
  end


  # e.g. save_submit_button_html "Save Choreographer", {class: "blahclasses"}
  def save_submit_button_html(label = "Save", opts={})
    opts = opts.clone
    opts[:class] = (opts[:class] || "") + " btn btn-lg btn-success"
    span = content_tag(:span, save_icon_html() + ' ' + label)
    button_tag span, opts
  end

  def sluggified_figure_path(move_name_containing_spaces_and_whatnot)
    raise "wrong type for parameter #{move_name_containing_spaces_and_whatnot.class}" unless move_name_containing_spaces_and_whatnot.is_a?(String)
    figure_path(JSLibFigure.slugify_move(move_name_containing_spaces_and_whatnot))
  end

  def move_links(moves, dialect)
    moves.map {|move| move_link(move, dialect)}.join(', ').html_safe
  end

  def move_link(move, dialect)
    label = html_escape(JSLibFigure.move_substitution(move, dialect))
    link_to(label, sluggified_figure_path(move))
  end
end
