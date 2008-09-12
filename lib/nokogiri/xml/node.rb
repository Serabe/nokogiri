module Nokogiri
  module XML
    class Node
      include Comparable

      DOCUMENT_NODE = 9
      HTML_DOCUMENT_NODE = 13
      DTD_NODE = 14
      ELEMENT_DECL = 15
      ATTRIBUTE_DECL = 16
      ENTITY_DECL = 17
      NAMESPACE_DECL = 18
      XINCLUDE_START = 19
      XINCLUDE_END = 20
      DOCB_DOCUMENT_NODE = 21

      def child; Node.wrap(ptr.children); end
      def next; ptr.next && Node.wrap(ptr.next); end
      def type; ptr.type; end

      def children
        list = []
        first = self.child
        list << first
        while first = first.next
          list << first
        end
        NodeSet.new { |s| s.to_a = list }
      end
      alias :getChildNodes :children

      def path
        DL::XML.xmlGetNodePath(ptr).to_s
      end

      def search(search_path)
        XPath.new(document, search_path)
      end
      alias :/ :search

      def [](property)
        property = DL::XML.xmlGetProp(
          ptr,
          DL::XML.xmlCharStrdup(property.to_s)
        )
        property && property.to_s
      end

      def []=(name, value)
        DL::XML.xmlSetProp(
          ptr,
          DL::XML.xmlCharStrdup(name.to_s),
          DL::XML.xmlCharStrdup(value.to_s)
        )
      end

      def has_property?(attribute)
        !property(attribute).nil?
      end
      alias :has_attribute? :has_property?

      def property(attribute)
        DL::XML.xmlHasProp(ptr, DL::XML.xmlCharStrdup(attribute.to_s))
      end

      def blank?
        1 == DL::XML.xmlIsBlankNode(ptr)
      end

      def xml?
        type == DOCUMENT_NODE
      end

      def html?
        type == HTML_DOCUMENT_NODE
      end

      def to_html
        serialize(:html)
      end

      def to_xml
        serialize(:xml)
      end

      def <=>(other)
        ptr.to_ptr <=> other.to_ptr
      end

      def to_ptr
        ptr.to_ptr
      end

      private
      # this just dumps stripped content. is there an easy way to dump a subtree in xml? i don't know.
      def serialize_node(type = :xml)
        buffer = DL::XML::Buffer.new(DL::XML.xmlBufferCreate())
        DL::XML.xmlNodeDump(buffer, ptr.doc, ptr, 2, 1)
        x = content.dup.to_s
        DL::XML.xmlBufferFree(buffer)
        return x
      end

      def serialize(type = :xml)
        raise "No document set" unless ptr.doc
        msgpt = ::DL.malloc(::DL.sizeof('P'))
        sizep = ::DL.malloc(::DL.sizeof('I'))
        DL::XML.send(:"#{type}DocDumpMemory", ptr.doc, msgpt.ref, sizep)
        msgpt.to_s
      end
    end
  end
end