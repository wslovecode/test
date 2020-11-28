# -*- coding:utf-8 -*-
'''
Author:王帅
Time:2020.11.27
'''

#创建写入、读取、插入XML文件的类
class RWXML:

    def __init__(self, filename):
        self.filename = filename

    def write_xml(self, rootname, name_information, father_item, child_item, text):

        import codecs
        import xml.dom.minidom
        # 在内存中创建一个空的文档
        doc = xml.dom.minidom.Document()
        # 创建一个根节点root对象
        root = doc.createElement(rootname)

        # 给根节点添加属性
        root.setAttribute('name', name_information)
        # 将根节点添加到文档对象中
        doc.appendChild(root)

        # 给根节点添加一个叶子节点
        father_item = doc.createElement(father_item)
        # 叶子节点下再嵌套叶子节点
        child_item = doc.createElement(child_item)
        # 给节点添加文本节点
        child_item.appendChild(doc.createTextNode(text))

        # 将各叶子节点添加到父节点father_item中
        father_item.appendChild(child_item)

        # 将father_item节点添加到根节点root中
        root.appendChild(father_item)

        # 此处需要用codecs.open可以指定编码方式
        fp = codecs.open(self.filename, 'w', 'utf-8')
        # 将内存中的xml写入到文件
        doc.writexml(fp, indent='', addindent='\t', newl='\n', encoding='utf-8')
        fp.close()

        print('添加的xml根节点为：',  root.tagName)
        print('添加的xml根节点名称信息为：',  name_information)
        print('添加的xml父节点为：',  father_item.tagName)
        print('添加的xml子节点为：',  child_item.tagName)
        print('添加的xml子节点文本为：',  text)

        print('写入XML文件成功！')
        print('**********************************')


    def read_xml(self, father_item, child_item):

        from xml.dom.minidom import parse
        # minidom解析器打开xml文档并将其解析为内存中的一棵树
        DOMTree = parse(self.filename)

        pp = DOMTree.toxml('utf-8')
        print("显示文件全部的xml格式内容：")
        print(pp)
        # 获取xml文档对象，就是拿到树的根
        father_item_list = DOMTree.documentElement
        father_items = father_item_list.getElementsByTagName(father_item)

        print("返回指定父节点下child：")
        for father_item in father_items:
            print('father_item is ', father_item.tagName)
            child_item = father_item.getElementsByTagName(child_item)[0]

            print('child_item is ', child_item.tagName)
            print('child_item text is ', child_item.childNodes[0].data)

        print('读取XML文件成功！')
        print('**********************************')


    def insert_xml(self, father_item1, child_item1, text1):

        from xml.etree.ElementTree import ElementTree, Element
        tree = ElementTree()
        tree.parse(self.filename)
        root = tree.getroot()

        father_item = Element(father_item1)
        child_item = Element(child_item1)
        child_item.text = text1

        father_item.append(child_item)
        root.append(father_item)
        tree.write(self.filename, encoding='utf-8', xml_declaration=True)

        print('插入的xml父节点为：',  father_item1)
        print('插入的xml子节点为：',  child_item1)
        print('插入的xml子节点文本为：',  text1)
        print('插入XML文件成功！')



if __name__ == '__main__':

    rwxml = RWXML(r'C:\Users\wangshuai\Desktop\dd.xml')

    # rwxml.write_xml('rootname', 'name_information', 'father_item1', 'child_item1', 'text1')
    # rwxml.read_xml(‘father_item1’, 'child_item1')
    # rwxml.insert_xml('father_item2', 'child_item2', 'text2')

    rwxml.write_xml('booklist', '书本信息', 'book1', 'type1', '一年级数学书本')
    rwxml.read_xml('book1', 'type1')
    rwxml.insert_xml('book2', 'type2', '二年级数学书本')








