package nokogiri.internals;

import java.util.List;
import javax.xml.xpath.XPathFunction;
import javax.xml.xpath.XPathFunctionException;
import nokogiri.XmlNode;
import nokogiri.XmlNodeSet;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyBoolean;
import org.jruby.RubyFloat;
import org.jruby.RubyString;
import org.jruby.javasupport.util.RuntimeHelpers;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author sergio
 */
public class NokogiriXPathFunction implements XPathFunction{
    private final IRubyObject handler;
    private final String name;
    private final int arity;

    public NokogiriXPathFunction(IRubyObject handler, String name, int arity) {
        this.handler = handler;
        this.name = name;
        this.arity = arity;
    }

    public Object evaluate(List args) throws XPathFunctionException {
        if(args.size() != this.arity) {
            throw new XPathFunctionException("arity does not match");
        }
        
        Ruby ruby = this.handler.getRuntime();
        ThreadContext context = ruby.getCurrentContext();

        IRubyObject result = RuntimeHelpers.invoke(context, this.handler,
                this.name, fromObjectToRubyArgs(args));

        return fromRubyToObject(result);
    }

    private IRubyObject[] fromObjectToRubyArgs(List args) {
        IRubyObject[] newArgs = new IRubyObject[args.size()];
        for(int i = 0; i < args.size(); i++) {
            newArgs[i] = fromObjectToRuby(args.get(i));
        }
        return newArgs;
    }

    private IRubyObject fromObjectToRuby(Object o) {
        Ruby ruby = this.handler.getRuntime();
        ThreadContext context = ruby.getCurrentContext();
        if(o instanceof String) {
            return ruby.newString((String) o);
        } else if (o instanceof Double) {
            return ruby.newFloat(((Double) o).doubleValue());
        } else if (o instanceof Boolean) {
            return ruby.newBoolean(((Boolean) o).booleanValue());
        } else if (o instanceof NodeList) {
            return new XmlNodeSet(ruby, (NodeList) o);
        } else /*if (o instanceof Node)*/ {
            return NokogiriHelpers.getCachedNodeOrCreate(ruby, (Node) o);
        }
    }

    private Object fromRubyToObject(IRubyObject o) {
        Ruby ruby = this.handler.getRuntime();
        ThreadContext context = ruby.getCurrentContext();
        if(o instanceof RubyString) {
            return o.convertToString().asJavaString();
        } else if (o instanceof RubyFloat) {
            return Double.valueOf(o.convertToFloat().getDoubleValue());
        } else if (o instanceof RubyBoolean) {
            return Boolean.valueOf(o.isTrue());
        } else if (o instanceof XmlNodeSet) {
            return ((XmlNodeSet) o).toNodeList(ruby);
        } else if (o instanceof RubyArray) {
            return (new XmlNodeSet(ruby, (RubyArray) o)).toNodeList(ruby);
        } else /*if (o instanceof XmlNode)*/ {
            return ((XmlNode) o).getNode();
        }
    }
}
