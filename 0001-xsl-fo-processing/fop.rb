require 'java'
# the `jars` directory must contain all the JAR dependencies
Dir["jars/*.jar"].each { |jar| require jar }

#Java
java_import java.io.File
java_import java.io.OutputStream

#JAXP
java_import javax.xml.transform.Transformer
java_import javax.xml.transform.TransformerFactory
java_import javax.xml.transform.Source
java_import javax.xml.transform.Result
java_import javax.xml.transform.stream.StreamSource
java_import javax.xml.transform.sax.SAXResult

#FOP
java_import org.apache.fop.apps.FOUserAgent
java_import org.apache.fop.apps.Fop
java_import org.apache.fop.apps.FopFactory
java_import org.apache.fop.apps.MimeConstants

def do_stuff
  puts "FOP ExampleXML2PDF\n"
  puts "Preparing..."

  # Setup directories
  baseDir = File.new(".")
  outDir = File.new(baseDir, "out")
  outDir.mkdirs()

  # Setup input and output files
  xmlfile = File.new(baseDir, "data.xml")
  xsltfile = File.new(baseDir, "fo.xsl")
  pdffile = File.new(outDir, "result.pdf")

  puts "Input: XML (#{xmlfile.path})"
  puts "Stylesheet: (#{xsltfile.path})"
  puts "Output: PDF (#{pdffile.path})\n"
  puts "Transforming..."

  # configure fopFactory as desired
  fopFactory = FopFactory.newInstance()

  foUserAgent = fopFactory.newFOUserAgent()
  # configure foUserAgent as desired

  # Setup output
  out = java.io.FileOutputStream.new(pdffile)
  out = java.io.BufferedOutputStream.new(out)

  begin
    # Construct fop with desired output format
    fop = fopFactory.newFop(MimeConstants::MIME_PDF, foUserAgent, out)

    # Setup XSLT
    factory = TransformerFactory.newInstance()
    transformer = factory.newTransformer(StreamSource.new(xsltfile))

    # Set the value of a <param> in the stylesheet
    transformer.setParameter("versionParam", "2.0")

    # Setup input for XSLT transformation
    src = StreamSource.new(xmlfile)

    # Resulting SAX events (the generated FO) must be piped through to FOP
    res = SAXResult.new(fop.getDefaultHandler())

    # Start XSLT transformation and FOP processing
    transformer.transform(src, res)
  ensure
    out.close()
  end

  puts "Success!"
end
