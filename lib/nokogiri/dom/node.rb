module Nokogiri
  module DOM
    module Node
      ELEMENT_NODE = 1
      ATTRIBUTE_NODE = 2
      TEXT_NODE = 3
      CDATA_SECTION_NODE = 4
      ENTITY_REFERENCE_NODE = 5
      ENTITY_NODE = 6
      PROCESSING_INSTRUCTION_NODE = 7
      COMMENT_NODE = 8
      DOCUMENT_NODE = 9
      DOCUMENT_TYPE_NODE = 10
      DOCUMENT_FRAGMENT_NODE = 11
      NOTATION_NODE = 12

      def nodeName
        return '#text' if text?
        name
      end

      def nodeValue
        content
      end

      def nodeValue= value
        self.content = value
      end

      def nodeType
        type
      end

      def parentNode
        parent
      end

      def childNodes
        children
      end

      def firstChild
        children.first
      end

      def lastChild
        children.last
      end

      def previousSibling
        previous_sibling
      end

      def nextSibling
        next_sibling
      end

      def attributes
        raise(NotImplementedError.new)
      end

      def ownerDocument
        return nil if self == document
        document
      end

      def insertBefore(newChild, refChild)
        raise(NotImplementedError.new)
      end

      def replaceChild(newChild, oldChild)
        raise(NotImplementedError.new)
      end

      def removeChild old_child
        old_child.remove
      end

      def appendChild(newChild)
        raise(NotImplementedError.new)
      end

      def hasChildNodes
        children.empty?
      end

      def cloneNode(deep)
        raise(NotImplementedError.new)
      end

      def normalize
        raise(NotImplementedError.new)
      end

      def isSupported(feature, version)
        raise(NotImplementedError.new)
      end

      def namespaceURI
        raise(NotImplementedError.new)
      end

      def prefix
        raise(NotImplementedError.new)
      end

      def prefix=(_)
        raise(NotImplementedError.new)
      end

      def localName
        raise(NotImplementedError.new)
      end

      def hasAttributes
        raise(NotImplementedError.new)
      end

      def baseURI
        raise(NotImplementedError.new)
      end

      DOCUMENT_POSITION_DISCONNECTED = 0
      DOCUMENT_POSITION_PRECEDING = 0
      DOCUMENT_POSITION_FOLLOWING = 0
      DOCUMENT_POSITION_CONTAINS = 0
      DOCUMENT_POSITION_CONTAINED_BY = 0
      DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 0
      def compareDocumentPosition(other)
        raise(NotImplementedError.new)
      end

      def textContent
        content
      end

      def textContent=(_)
        raise(NotImplementedError.new)
      end
      def isSameNode(other)
        raise(NotImplementedError.new)
      end
      def lookupPrefix(namespaceURI)
        raise(NotImplementedError.new)
      end
      def isDefaultNamespace(namespaceURI)
        raise(NotImplementedError.new)
      end
      def lookupNamespaceURI(prefix)
        raise(NotImplementedError.new)
      end
      def isEqualNode(arg)
        raise(NotImplementedError.new)
      end
      def getFeature(feature, version)
        raise(NotImplementedError.new)
      end
      def setUserData(key, data, handler)
        raise(NotImplementedError.new)
      end
      def getUserData(key)
        raise(NotImplementedError.new)
      end
    end
  end
end