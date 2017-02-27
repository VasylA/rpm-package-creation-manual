#!/usr/bin/python
# coding=utf-8
import sys
import re
import redmine
import textile
import string
import os
import getopt
import cgi

from redmine.exceptions import AuthError


text_templates = {'body':        '<head>\n'
                                 '<link rel="stylesheet" type="text/css" href="qrc:///StyleSheets/Help/general.css">\n'
                                 '<meta charset=\"UTF-8\">\n</head>\n'
                                 '<body>\n'
                                 '%s\n'
                                 '</body>',
                  'table_style': 'border="1" style="border-color: #808080; border-width: 1px;" cellspacing="0" cellpadding="5"'}

li_styles = {1: u'<p class = "li1">• ',
             2: u'<p class = "li2">- ',
             3: u'<p class = "li3">• ',
             4: u'<p class = "li4">- ',
             5: u'<p class = "li5">• '}

revisions = {'SLG46200V':       'GP1',

             'SLG46400V':       'GP2',
             'SLG46400V_Rev_B': 'GP2',

             'SLG46721V':       'GP3',
             'SLG46722V':       'GP3',
             'SLG46724V':       'GP3',
             'SLG46108V':       'GP3',
             'SLG46110V':       'GP3',
             'SLG46116V':       'GP3',
             'SLG46117V':       'GP3',
             'SLG46118V':       'GP3',
             'SLG46119V':       'GP3',
             'SLG46120V':       'GP3',
             'SLG46121V':       'GP3',
             'SLG46125M':       'GP3',
             'SLG46127M':       'GP3',
             'SLG46169V':       'GP3',
             'SLG46170V':       'GP3',

             'SLG46620V':       'GP4',
             'SLG46621V':       'GP4',
             'SLG46140V':       'GP4',

             'SLG46515M':       'GP5',
             'SLG46517M':       'GP5',
             'SLG46531V':       'GP5',
             'SLG46532V':       'GP5',
             'SLG46533V':       'GP5',
             'SLG46534V':       'GP5',
             'SLG46535V':       'GP5',
             'SLG46536V':       'GP5',
             'SLG46537V':       'GP5',
             'SLG46538V':       'GP5',
             'SLG46580V':       'GP5',

             'SLG46880V':       'GP6'}

save_path = '/home/vasyl/Documents/Redmine/gp_help'
project_name = 'greenpak-help'
content_page_template = 'Materials_for_Help_Widget_(%s)'
server = 'http://172.21.1.21/redmine'
access_key = 'a084ce788aae1f23de04a5fa00b4516a61b26970'


def get_revision(text):
    """
    :param text: string to search for revision name
    :return: revision name if found or None
    """
    p = re.compile('\(SLG\d{5}.*\)')
    m = p.search(text)
    if m:
        return m.group()[1:-1]
    else:
        return None


def get_name(text):
    """
    :param text: wiki page name formatted as '<name>_(SLG<revision>V<optional symbols>)'
    :return: separated name
    """
    name = text.split('_(', 1)
    return name[0]


def check_folder(path, revision):
    """
    Ensures folder for given revision exists

    :param path: help files output folder without trailing slash
    :param revision: string formatted as 'SLG<revision>V<optional symbols>'
    :return: full path for document of passed revision
    """
    directory = path + '/' + revisions[revision] + '/' + revision + '/'
    try:
        os.makedirs(directory)
    except OSError:
        if not os.path.isdir(directory):
            raise
    return directory


def search_for_reference(text):
    """
    Searches wiki page text for reference to another page

    :param text: wkik page text
    :return: name of referenced wiki page or None
    """
    if text.find('Referred to', 0, 195) >= 0:
        p = re.compile('\[\[.*?(_| )\(.*?\)(\||])')
        m = p.search(text)
        if m:
            return m.group()[2:-1].replace(' ', '_')
    return None


def is_list_line(line):
    """
    Checks text if it is a list line

    :param line: text line
    :return: boolean
    """
    p = re.compile('^\*{1,} ')
    m = p.search(line)
    if m:
        return True
    else:
        return False


def detect_li_indent(text):
    """
    Calculates given list item indent

    :param text: list item
    :return: indent (nested) level (0 to 5)
    """
    indent = 0
    for symbol in text:
        if symbol != '*':
            break
        indent += 1
    return indent % 6  # limits max list nesting


def process_ul_list(list_text):
    """
    Processes list: creates list item paragraph and applies

    :param list_text: list items as list
    :return: list with converted list items
    """
    lines = ['<p>']
    for line in list_text:
        indent = detect_li_indent(line)
        tmp_line = textile.textile(line[indent:]).replace('<p>', li_styles[indent], 1)
        lines.append(tmp_line)
    lines.append('</p>')
    return lines


def process_ul_lists(text):
    """
    Searches text for unordered lists (lines starting with '*') and converts them to styled paragraphs

    :param text: help file text
    :return: help file text with converted lists
    """
    tmp_list = []
    lines = text.split('\r\n')
    new_lines = []
    for line in lines:
        if is_list_line(line):
            tmp_list.append(line)
        else:
            if len(tmp_list) > 0:
                new_lines += process_ul_list(tmp_list)
                del tmp_list[:]
            new_lines.append(line)
    else:
        if len(tmp_list) > 0:
                new_lines += process_ul_list(tmp_list)
                del tmp_list[:]
    return '\r\n'.join(new_lines)


def process_wiki_page(srv, project, page_name):
    """
    Saves wiki help page contents (.html file) and attachments to folder selected by revision & global path

    :param srv: connected redmine server
    :param project: name of the project which holds wiki pages
    :param page_name: wiki page which contains block help
    """

    revision = get_revision(page_name)
    try:
        wiki_page = srv.wiki_page.get(page_name, project_id=project, include='attachments')
    except redmine.exceptions.ResourceNotFoundError:
        print 'ERROR: %s\'s page "%s" not found! Skipping.' % (revision, page_name)
        return

    text = wiki_page['text']

    # process references
    reference = search_for_reference(text)
    if reference:
        wiki_page = srv.wiki_page.get(reference, project_id=project, include='attachments')
    text = wiki_page['text']
    text = cgi.escape(text)  # escaping HTML special symbols
    text = text.split('\r\n', 1)  # splitting first line
    text = process_ul_lists(text[1])
    text = textile.textile(text, encoding='utf-8')  # processing text without first line
    text = text.replace('<table>', '<table %s>' % text_templates['table_style'])  # applying table styles
    text = text.replace('</h4>', '</h4><hr>')  # add line after .h4 header
    text = text.replace('p style="padding-l', 'p style="margin-l')  # workaround for old WebKit

    pattern = '<p.*><img.*\/>.*[\n]?.*<\/p>'
    p = re.compile(pattern)

    occurrences = p.findall(text)
    for substr in occurrences:
        centered_str = "%s%s%s" % ('<center>', substr, '</center>')
        text = re.sub(substr, centered_str, text)

    filename = get_name(page_name)
    name = get_name(page_name)

    path = check_folder(save_path, revision)

    # saving attached files
    for attachment in wiki_page.attachments:
        attachment.download(savepath=path)

    # saving help file
    outfile = path + filename + '.html'
    text_to_write = (text_templates['body'] % text).encode('utf-8_sig')

    file_out = open(outfile, "wb")
    file_out.write(text_to_write)
    file_out.close()

    print "%s %s in %s is ready." % (revision, name, outfile)


def extract_name(line):
    """
    :param line: text line of contents page to analyze ( [[ page_name | some text ]] or [[ page name ]])
    :return: page name string
    """
    end = line.rfind('|')
    if end >= 0:
        start = line.rfind('[', 0, end)
        if start >= 0:
            return line[start+1:end].replace(' ', '_')
    else:
        end = line.find(']')
        if end >= 0:
            start = line.rfind('[', 0, end)
            return line[start+1:end].replace(' ', '_')
    return None


def process_wiki_content_page(srv, project, page_name):
    """
    Processes given revision content wiki page to extract wiki help page names list for every block

    :param srv: connected redmine server
    :param project: name of the project which holds wiki pages
    :param page_name: name of the revision content page which holds list of links to help pages
    :return: list of wiki help page names
    """
    names = []
    try:
        content_page = srv.wiki_page.get(page_name, project_id=project)
    except redmine.exceptions.ResourceNotFoundError:
        print 'ERROR: Page "%s" not found! Skipping.' % page_name
        return names

    lines = content_page['text'].split('\r\n')

    for line in lines:
        page_name = extract_name(line)
        if page_name:
            names.append(page_name)
    return names


def get_wiki_page_list(srv, project):
    """
    Processes "Materials_for_Help_Widget" wiki pages for every revision & extracts wiki help pages list for every block

    :param srv: connected redmine server
    :param project: name of the project which holds necessary wiki pages
    :return: list of wiki page names with help materials
    """
    page_names = []
    for revision in revisions.keys():
        page_names += process_wiki_content_page(srv, project, content_page_template % revision)
    return page_names
    # return ['LUT_DFF_LATCH_(SLG46724V)']  # for debug


def main(argv):
    parser_mode = {'all', 'revision', 'page'}
    opts, args = getopt.getopt(argv, "", ["path=", "revision=", "page="])
    arg_dict = dict(opts)
    mode = 'all'

    if '--path' in arg_dict:
        global save_path
        save_path = arg_dict['--path']

    if not os.path.isdir(save_path):
        print "Path '%s' do not exists" % save_path
        exit(1)

    if '--page' in arg_dict:
        page = arg_dict['--page']
        mode = 'page'
    elif '--revision' in arg_dict:
        revision = arg_dict['--revision']
        mode = 'revision'

    # pass key & path as arguments
    srv = redmine.Redmine(server, key=access_key)
    try:
        srv.auth()
    except AuthError:
        print "Invalid access key!"
        exit(1)

    if mode == 'page':
        process_wiki_page(srv, project_name, page)
    elif mode == 'revision':
        pages = process_wiki_content_page(srv, project_name, content_page_template % revision)
        count = len(pages)
        i = 0
        for page_name in pages:
            i += 1
            print '[%d/%d]' % (i, count),
            process_wiki_page(srv, project_name, page_name)
    else:
        pages = get_wiki_page_list(srv, project_name)
        count = len(pages)
        i = 0
        for page_name in pages:
            i += 1
            print '[%d/%d]' % (i, count),
            process_wiki_page(srv, project_name, page_name)


if __name__ == "__main__":
    main(sys.argv[1:])
