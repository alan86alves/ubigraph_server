<div class=manual>

define(KNOWN_BUG, `<div class="bugs">&#x2622; Ticket#$1 $2</div>')
define(TIP, `<div class="tips">&#x261E; $1</div>')
define(TIPS, `<div class="tips">$1</div>')
define(SUBTIP, `&#x261E; $1<br>')

<div class=nav>
<p>Major topics:</p>
<ul>
<li><a href="#gettingstarted">Getting started</a></li>
<li><a href="#basicapi">Basic API functions</a></li>
<li><a href="#languagebindings">Language bindings</a></li>
<li><a href="#vertexattributes">Vertex attributes</a></li>
<li><a href="#edgeattributes">Edge attributes</a></li>
<li><a href="#styles">Styles-ids and the style model</a></li>
<li><a href="#performance">Performance issues</a></li>
</ul>
</div>

<h1>UbiGraph XML-RPC Manual</h1>

ifdef(`MANUALSUBHEADING', MANUALSUBHEADING())

<p>
Ubigraph is a system for visualizing dynamic graphs.
This version is shipped in binary form as a standalone
server that responds to requests using XML-RPC.
This makes it easy to use from C, C++, Java, Ruby, Python,
Perl,
and other languages for which XML-RPC implementations
are available.  Since XML-RPC uses TCP-IP, the server
(which visualizes the graph) can be run on a different
machine/operating system than the client (which is manipulating
the graph).
It is also possible to have multiple clients
updating the graph simultaneously.
(Note that for clients to be on different machines from
the server, firewalls must be configured to allow traffic
on port 20738.)
</p>

<h3>Quick Start</h3>

<p>
After <a href="http://ubietylab.net/ubigraph/content/Downloads/">downloading</a>
the release:
</p>

<div class=example>
<pre>
$ gunzip UbiGraph-....tgz
$ tar xvf UbiGraph-....tar
$ cd UbiGraph-...
$ bin/ubigraph_server &                    (empty black window)
$ cd examples/Python
$ ./run_all.sh
</pre>
</div>

<p>
If you're familiar with Python, a good place to start is
<tt>examples/Python/ubigraph_example.py</tt>.  This example
illustrates the higher-level API for ubigraph in Python:
</p>

<div class="figure">
<img src="images/ubigraph_py.png">
</div>

<div class="example">
<pre>
import ubigraph

U = ubigraph.Ubigraph()
U.clear()

x = U.newVertex(shape="sphere", color="#ffff00")
  
smallRed = U.newVertexStyle(shape="sphere", color="#ff0000", size="0.2")
  
previous_r = None
for i in range(0,10):
  r = U.newVertex(style=smallRed, label=str(i))
  U.newEdge(x,r,arrow=True)
  if previous_r != None:
    U.newEdge(r,previous_r,spline=True,stroke="dashed")  
  previous_r = r
</pre>
</div>

<h3>Reporting problems</h3>
<p>
This is alpha software.  Please help us (and other users)
by reporting problems you encounter.  Problems
can be emailed to <tt>support@ubietylab.net</tt>.
Please also see the <a href="http://ubietylab.net/ubigraph/content/Support/index.html">suggestions on the web site</a> about submitting bug reports.
</p>

<a name="gettingstarted"></a>
<h2>Getting started</h2>

<p>
This version of the ubigraph software is shipped in binary form
as a standalone server.  Clients talk to the server using
XML-RPC, a standard remote procedure call protocol
that uses HTTP-POST requests to call methods.  The method call
and return results are encoded with XML.
The use of XML-RPC makes it trivial to use Ubigraph with
popular scripting languages such as Python and Ruby.
</p>

<h3>Starting and using the server</h3>

<p>The server process must be started before any clients
can connect to it.  To do this, just run
the <b><tt>ubigraph_server</tt></b> program
found in the bin subdirectory of the distribution.
You should be rewarded with a message
("Running Ubigraph/XML-RPC server.")
and a new window which is empty and black.
</p>

TIP(`If you get an error message such as
"Failed to bind listening socket to port number 20738,"
check if the server is already running, e.g.,
<tt>ps aux | grep ubigraph</tt>')
TIP(`If you are missing shared libraries,
there are two things to consider.  If the missing
libraries are core system libraries such as libc,
you probably need to download a different version of
ubigraph.  If you are missing e.g. libGL, libGLU,
libglut, you probably just need to use your
system package manager to install them.')

<p>
You can now run the programs included with the
distribution.
In developing UbiGraph we were focussed on
the layout algorithm, with the result that the
GUI is still somewhat primitive.  You can rotate the graph
by holding the left mouse button and dragging.
Dragging with the middle mouse button pans.
There is a right-mouse button
menu that will let you switch into fullscreen mode.
A number of keystrokes are recognized:

<table>
<tr><th>Key(s)</th>      <th>Function</th></tr>
<tr><td>ESC</td>         <td>Exit full-screen mode</td></tr>
<tr><td>&uarr; and &darr;</td>     <td>Zoom in/out</td></tr>
<tr><td>!</td>           <td>Zoom way out</td></tr>
<tr><td>@</td>           <td>Zoom way in</td></tr>
<tr><td>&larr; and &rarr;</td>     <td>Start/increase/stop y-axis rotation</td></tr>
<tr><td>u, d</td>        <td>Start/increase/stop z-axis rotation</td></tr>
<tr><td>r</td>           <td>Reset vertices to random positions</td></tr>
<tr><td>+,-</td>         <td>Increase/decrease time step</td></tr>
<tr><td>h</td>           <td>Toggle Runge-Kutta/Euler step</td></tr>
<tr><td>p</td>           <td>Toggle serial/parallel</td></tr>
<tr><td>f,F</td>         <td>Decrease/increase friction</td></tr>
<tr><td>v</td>           <td>Toggle draw vertices</td></tr>
<tr><td>s</td>           <td>Toggle draw strain</td></tr>
<tr><td>S</td>           <td>Show performance stats</td></tr>
</table>

</p>

<h3>The XML protocol layer</h3>

<p>
You shouldn't need to worry about the XML layer unless you are
implementing your own client interface in some language that is
not yet supported.
However, if you're curious to see what the messages being sent to and from
the server look like, set <b><tt>XMLRPC_TRACE_XML=1</tt></b> in 
your environment
before running <b><tt>ubigraph_server</tt></b>.  Here is an example call-response
pair, which creates a new edge from vertex 0 to vertex 9, which
is given an edge-id 423265977 by the server.
</p>

<div class=example>
<pre>
XML-RPC CALL:

&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;methodCall&gt;
&lt;methodName&gt;ubigraph.new_edge&lt;/methodName&gt;
&lt;params&gt;
&lt;param&gt;&lt;value&gt;&lt;i4&gt;9&lt;/i4&gt;&lt;/value&gt;&lt;/param&gt;
&lt;param&gt;&lt;value&gt;&lt;i4&gt;0&lt;/i4&gt;&lt;/value&gt;&lt;/param&gt;
&lt;/params&gt;
&lt;/methodCall&gt;

XML-RPC RESPONSE:

&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;methodResponse&gt;
&lt;params&gt;
&lt;param&gt;&lt;value&gt;&lt;i4&gt;423265977&lt;/i4&gt;&lt;/value&gt;&lt;/param&gt;
&lt;/params&gt;
&lt;/methodResponse&gt;
</pre>
</div>

<a name="basicapi"></a>
<h2>The basic API functions</h2>

<p>
The five functions shown below cover the basic operations.
API functions are presented in C language syntax, but the
way these are adapted to other languages is straightforward.
</p>

<div class=example>
<pre>
void        ubigraph_clear();
int         ubigraph_new_vertex();
int         ubigraph_new_edge(int x, int y);
int         ubigraph_remove_vertex(int x);
int         ubigraph_remove_edge(int e);
</pre>
</div>

<p>
<b><tt>ubigraph_clear</tt></b> resets the graph, deleting any vertices and
edges that exist.  It's a good idea to call this method at the beginning of
any session, in case a previous client failed to clean up.
</p>

<p>
<b><tt>new_vertex</tt></b> creates a vertex, and returns its vertex-id
(an integer).  You need to remember this vertex-id to create edges with
<b><tt>new_edge</tt></b>, which creates an edge between two vertices
(specified by their vertex-ids), and returns its edge-id (an integer).  
To delete a vertex, call
<b><tt>ubigraph_remove_vertex</tt></b> and supply its vertex-id; any
edges touching the vertex are removed also.  To delete an edge, call
<b><tt>ubigraph_remove_edge</tt></b> and supply its edge-id.
The remove methods return 0 on success, or -1 on failure
(i.e., you tried to remove an edge or vertex that did not exist.)
</p>

<h3>Specifying vertex and edge ids</h3>

<p>
If you do not want to keep track of vertex or edge-id's, there is
an alternate pair of API routines that allow you to specify the
vertex-id and edge-id when creating vertices and edges:
</p>

<div class=example>
<pre>
int         ubigraph_new_vertex_w_id(int id);
int         ubigraph_new_edge_w_id(int id, int x, int y);
</pre>
</div>
These routines return 0 on success, or -1 if the requested id
is already in use.

TIP(`All id numbers (vertex-ids, edge-ids, style-ids) created by the 
ubigraph API are between <tt>0x40000000</tt> and <tt>0x7fffffff</tt>, inclusive.
You may find this fact useful if you are mixing ubigraph-generated id
numbers with your own id numbers.')

<a name="languagebindings"></a>
<h2>Language Bindings</h2>

<p>
In the xmlrpc subdirectory of the distribution you can find bindings and/or
examples of how to use the ubigraph server from various programming
languages.  
</p>

<p>
Python and Ruby are the easiest to get working, since XML-RPC is included
in the standard libraries for these languages.  For Java, you will need to
install a .jar package for XMLRPC support.  For C and C++ you will need to
install the XMLRPC-C and libwww libraries.
</p>

<h3>Python</h3>


<p>
XML-RPC is included in the Python standard library.
An example usage is shown below:
</p>

<div class=figure>
<img src="images/Ring.png" width=150 alt="Example graph layout">
</div>

<div class=example>
<pre>
import xmlrpclib

# Create an object to represent our server.
server_url = 'http://127.0.0.1:20738/RPC2'
server = xmlrpclib.Server(server_url)
G = server.ubigraph

# Create a graph
for i in range(0,10):
    G.new_vertex_w_id(i)

# Make some edges
for i in range(0,10):
    G.new_edge(i, (i+1)%10)
</pre>
</div>

<p>
Ubigraph is distributed with a collection of Python examples.
You can run them all using the script <tt>run_all.sh</tt>
in the <tt>examples/Python</tt> subdirectory.
</p>

<h4>Using Python interactively</h4>

<p>
Python provides an easy way to experiment with the
API and styles.  If you start an interactive Python
session and paste in the first few lines above,
you can then generate some vertices and play with
their styles.
</p>

<div class=figure>
<img src="images/PythonInteractive.png">
</div>

<div class=example>
<pre>
$ python
Python 2.3.5 (#1, Apr 25 2007, 00:02:14) 
Type "help", "copyright", "credits" or "license" for more information.
>>> import xmlrpclib
>>> server = xmlrpclib.Server('http://127.0.0.1:20738/RPC2')
>>> G = server.ubigraph
>>> x = G.new_vertex()
>>> y = G.new_vertex()
>>> G.new_edge(x,y)
335979033
>>> G.set_vertex_attribute(x, 'color', '#ff0000')
0
>>> G.set_vertex_attribute(y, 'shape', 'torus')
0
>>> G.set_vertex_attribute(y, 'color', '#ffff40')
0
>>> G.set_vertex_attribute(x, 'label', 'This is red')
0
</pre>
</div>

TIP(The above example can be found in <tt>examples/Python/interact.py</tt>.)

<br>
<h4>A more friendly Python API: ubigraph.py</h4>

<p>
In examples/Python you will find ubigraph.py, which provides a
higher-level interface to ubigraph:
</p>

<div class="figure">
<img src="images/ubigraph_py.png">
</div>

<div class="example">
<pre>
import ubigraph

U = ubigraph.Ubigraph()
U.clear()

x = U.newVertex(shape="sphere", color="#ffff00")

smallRed = U.newVertexStyle(shape="sphere", color="#ff0000", size="0.2")

previous_r = None
for i in range(0,10):
  r = U.newVertex(style=smallRed, label=str(i))
  U.newEdge(x,r,arrow=True)
  if previous_r != None:
    U.newEdge(r,previous_r,spline=True,stroke="dashed")
  previous_r = r
</pre>
</div>

TIP(`The above example can be found in <tt>examples/Python/ubigraph_example.py</tt>.')

<h3>Ruby</h3>

<p>
XML-RPC is included with Ruby.  Here is an example program:

<div class=figure>
<img src="images/Ring.png" width=150 alt="Example graph layout">
</div>

<div class=example>
<pre>
require 'xmlrpc/client'

server = XMLRPC::Client.new2("http://127.0.0.1:20738/RPC2")

for id in (0..9)
  server.call("ubigraph.new_vertex_w_id", id)
end

for id in (0..9)
  server.call("ubigraph.new_edge", id, (id+1)%10)
end
</pre>
</div>
</p>

<h4>Rubigraph</h4>
<p>
<a href="http://deadbeaf.org/">Motohiro Takayama</a>
has written a nicer interface, Rubigraph, which hides the
XMLRPC details:
</p>

<div class=example>
<pre>
require 'rubigraph'

Rubigraph.init        # initialize XML-RPC client.

v1  = Vertex.new
v2  = Vertex.new
e12 = Edge.new(v1, v2)

v1.color  = '#003366'
v2.shape  = 'sphere'
e12.label = 'edge between 1 and 2'
</pre>
</div>

<p>
Rubigraph can be found in the subdirectory
<tt>examples/Ruby/Rubigraph</tt>.  It is
distributed under an MIT license.  
</p>

TIP(`
Ubigraph is distributed with the latest version of Rubigraph
as of packaging time.  More recent versions of Rubigraph can be
obtained from 
<a href="http://coderepos.org/share/browser/lang/ruby/rubigraph/">CodeRepos</a> using subversion:

<div class=example>
<pre>
$ svn checkout http://svn.coderepos.org/share/lang/ruby/rubigraph
</pre>
</div>

or from RubyForge with git:

<div class=example>
<pre>
$ git clone git:://rubyforge.org/rubigraph.git
</div>
'
)

<h3>Perl</h3>

<p>
XML-RPC can be used with Perl via the Frontier::Client,
available from CPAN as part of the Frontier-RPC package.
</p>

<div class=example>
<pre>
#!/usr/bin/perl
use Frontier::Client;
my $client = Frontier::Client->new( url => 'http://127.0.0.1:20738/RPC2';);
$client->call('ubigraph.clear', 0);
my $a = $client->call('ubigraph.new_vertex');
my $b = $client->call('ubigraph.new_vertex');
$client->call('ubigraph.new_edge', $a, $b)
</pre>
</div>

<h3>Java</h3>

<p>
You will need to install Apache XML-RPC for Java, which can be obtained
from <a href="http://ws.apache.org/xmlrpc/">http://ws.apache.org/xmlrpc/</a>.
The .jar files in the lib subdirectory of the Apache XML-RPC binary
distribution should be placed in your usual CLASSPATH.

TIP(Mac OS X: copy the .jar files to /System/Library/Java/Extensions.)
</p>

<p>
In the xmlrpc/Java subdirectory of the ubigraph distribution
you will find ubigraph.jar, which provides a class
<tt>org.ubiety.ubigraph.UbigraphClient</tt> that hides the xmlrpc details.
Javadoc for this class can be found in the xmlrpc/Java/html
subdirectory of the distribution.  An example use is shown
below:
<div class=figure>
<img src="images/Ring.png" width=150 alt="Example graph layout">
</div>

<div class=example>
<pre>
import org.ubiety.ubigraph.UbigraphClient;

public class Example {

public static void main(String[] args) {
  UbigraphClient graph = new UbigraphClient();

  int N = 10;
  int[] vertices = new int[N];

  for (int i=0; i < N; ++i)
    vertices[i] = graph.newVertex();

  for (int i=0; i < N; ++i)
    graph.newEdge(vertices[i], vertices[(i+1)%N]);
}

}
</pre>
</div>
</p>

<h3>C</h3>

<p>
An API is provided for C and C++ that hides the underlying XML-RPC
implementation.  Once you have this API built, using it is very
simple, e.g.:

<div class=example>
<pre>
#include &lt;UbigraphAPI.h&gt;

int main(int const argc, const char ** const argv)
{
  int i;
  for (i=0; i < 10; ++i)
    ubigraph_new_vertex_w_id(i);

  for (i=0; i < 10; ++i)
    ubigraph_new_edge(i, (i+1)%10);

  sleep(2);

  ubigraph_clear();
}
</pre>
</div>
</p>

<h4>Building the C language API</h4>

<p>
The xmlrpc/C subdirectory of the ubigraph distribution
contains some things you will need to build.  Here is how to proceed:
<ol>
<li>If you do not already have it, you will need to install 
XML-RPC for C/C++ (Xmlrpc-c), which can be obtained
from 
<a href="http://xmlrpc-c.sourceforge.net/">http://xmlrpc-c.sourceforge.net/</a>.

TIPS(
SUBTIP(`Ubuntu: <tt>sudo apt-get install libxmlrpc-c3-dev</tt>')
SUBTIP(`Fedora: you can install the package <tt>xmlrpc-c-devel-1.13.8-2.fc9</tt>')
)

TIP(`The following should download and install xmlrpc-c on most platforms:
<div class="example">
<pre>
$ svn checkout https://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/stable xmlrpc-c
$ cd xmlrpc-c
$ ./configure --disable-libwww-client --enable-curl-client
$ make -i 
$ sudo make install
</pre>
</div>
')

</li>
<li>In the xmlrpc/C subdirectory of the ubigraph distribution, you
will need to do "make libubigraphclient" to build a library
(libubigraphclient.a) which provides the C language API.
</li>
<li>When linking your C programs to the C language API,
these libraries will be required:

<pre>
-lubigraphclient -lxmlrpc_client -lxmlrpc -lxmlrpc_util 
-lxmlrpc_xmlparse -lxmlrpc_xmltok
</pre>

The xmlrpc libraries should be installed in one of the
standard library paths (e.g., /usr/include/lib).
For the linker to find libubigraphclient.a, you will
need to either copy this to a standard library 
path, or include the path with a -L option.

TIP(`If you get undefined symbols that start with _HT...., then your xmlrpc-c libraries were built with libwww transport enabled.  You will need to make sure libwww is installed, and link with:
<pre>
-lwwwapp -lwwwfile -lwwwhttp -lwwwnews -lwwwutils -lwwwcache -lwwwftp -lwwwinit -lwwwstream -lwwwxml -lwwwcore -lwwwgopher -lwwwmime -lwwwtelnet -lwwwzip -lwwwdir -lwwwhtml -lwwwmux -lwwwtrans -lmd5 -lxmlparse -lxmltok
</pre>
')

</li>
</ol>

</p>

<h3>C++</h3>

<p>
Follow the instructions for C, above.  Use extern "C" when
including the header file, e.g.:

<div class=figure>
<img src="images/Ring.png" width=150 alt="Example graph layout">
</div>

<div class=example>
<pre>
extern "C" {
#include &lt;UbigraphAPI.h&gt;
}

int main(int const argc, const char ** const argv)
{
  for (int i=0; i < 10; ++i)
    ubigraph_new_vertex_w_id(i);

  for (int i=0; i < 10; ++i)
    ubigraph_new_edge(i, (i+1)%10);

  sleep(2);

  ubigraph_clear();
}
</pre>
</div>

</p>

<a name="vertexattributes"></a>
<h2>Vertex Attributes</h2>

<p>
Vertex attributes can be set with the following
function:
</p>

<div class=example>
<pre>
int   ubigraph_set_vertex_attribute(int x,
        string attribute, string value);
</pre>
</div>

<p>
However, if you have a large number of vertices with
similar attributes, you should use style-ids, as
described later.
</p>

<div class=tabular>
<table>
<tr>
<th>Attribute</th>
<th>Values</th>
<th>Default</th>
</tr>

<tr>
<td>color</td>
<td>String of the form "#000000" specifying an rgb triple; or
an integer such as "31" to use the built-in palette.</td>
<td>"#0000ff"</td>
</tr>

<tr>
<td>shape</td>
<td>
<img src="images/shape_cone.png">
<img src="images/shape_cube.png">
<img src="images/shape_dodecahedron.png">
<img src="images/shape_icosahedron.png">
<img src="images/shape_octahedron.png">
<img src="images/shape_sphere.png">
<img src="images/shape_tetrahedron.png">
<img src="images/shape_torus.png">
<br clear="all">
Use "none" to draw nothing.
TIP(`Cones, spheres, and tori can be expensive to draw.  For graphs with many vertices, you can sometimes improve performance by switching to simpler shapes.')
KNOWN_BUG(340745, The image of the tetrahedron actually shows an octahedron)
</td>
<td>"cube"</td>
</tr>

<tr>
<td>shapedetail</td>
<td>
<div class=figure>
<img src="images/shapedetail.png" width=250>
</div>
Indicates the level of detail with which the shape should be rendered.  This is relevant only for the sphere, cone, and torus shapes,
which are described by polygons.  Performance may improve for large graphs if the level of detail is reduced.  Sensible values from 5 to 40.  If shapedetail=0, the level of detail varies with the framerate.
</td>
<td>10</td>
</tr>

<tr>
<td>label</td>
<td>A string to be displayed near the vertex.</td>
<td>""</td>
</tr>

COMMENT(
<tr>
<td>labelpos</td>
<td>Where to display the label, relative to the vertex.
This vector is multiplied by the vertex size to calculate
the label offset.  (i.e., if you double the size of a
vertex, the label position will automatically adjust itself.)
<b>Implemented in libubiety, but yet in UbigraphAPI.</b>
</td>
<td>[0,1.2,0]</td>
</tr>
)

COMMENT(
<tr>
<td>orientation</td>
<td>3-vector indicating the direction in which the shape is
oriented.
<b>Not yet implemented.</b>
</td>
<td>"[0.0,1.0,0.0]".</td>
</tr>
)

<tr>
<td>size</td>
<td>
<div class=figure>
<img src="images/size.png">
</div>
Real number indicating the relative size of the shape.
This is for rendering only, and does not affect layout.
</td>
<td>1.0</td>
<tr>

<tr>
<td>fontcolor</td>
<td>String of the form "#000000" specifying an rgb triple,
or an integer to use the built-in palette.
</td>
<td>"#ffffff"</td>
</tr>

<tr>
<td>fontfamily</td>
<td>String indicating the font to be used for the label.
Recognized choices are "Helvetica" and "Times Roman".
Only the combinations of family and size shown below
are recognized; other choices of family and size 
result in a `best guess'.<br><br>
<img src="images/font_helvetica10.png">
<img src="images/font_helvetica12.png">
<img src="images/font_helvetica18.png">
<img src="images/font_timesroman10.png">
<img src="images/font_timesroman24.png">
</td>
<td>Helvetica</td>
</tr>

<tr>
<td>fontsize</td>
<td>Integer giving the size of the font, in points, used for
the label.
</td>
<td>12</td>
</tr>

COMMENT(
<tr>
<td>manifold</td>
<td>The id of a manifold to which this vertex should
be restricted.  <b>Not yet implemented.</b></td>
<td>0</td>
</tr>
)

<tr>
<td>visible</td>
<td>Whether this vertex is drawn.

TIP(`You can hide and reveal aspects of the graph by manipulating
the "visible" attribute of vertex and edge styles.  This trick can
also be used to hide the construction and layout of graphs.')
</td>
<td>true</td>
</tr>

</table>
</div>

TIP(`Where the ubigraph API expects a boolean value
(true or false), the strings "true", "True", "1", "false",
"False", and "0" may be used.  However, an integer 0 or 1
will not work.')

<p>
The following vertex attributes are intended for eventual
inclusion in an "Ubigraph Pro" (i.e., not free) version.
<b>Please be cautioned that they may disappear from the 
free version in the future.</b>
</p>

<div class=tabular>
<table>
<tr>
<th>Attribute</th>
<th>Values</th>
<th>Default</th>
</tr>

<tr>
<td>callback_left_doubleclick</td>
<td>Action to take when the user double-clicks the left mouse
button on the vertex.  Currently the only supported action
is a URL such as "http://hostname.net/method_name".  This
will result in an XMLRPC call being made, with the vertex-id
passed as the only parameter.

TIP(Use of this attribute is illustrated in
<tt>examples/Python/callback.py</tt> and
<tt>examples/Python/callback_webcrawler.py</tt>.)
</td>
<td>
""
</td>
</tr>

COMMENT(
<tr>
<td>expire_in</td>
<td>The number of seconds in which the vertex will be
automatically deleted, if no further calls to expire
are made.  A value of 0 means "do not expire."</td>
<td>0</td>
</tr>
)

</table>
</div>

<a name="edgeattributes">
<h2>Edge attributes</h2>

<p>
Edge attributes can be set with the following
function:
</p>

<div class=example>
<pre>
int   ubigraph_set_edge_attribute(int x,
        string attribute, string value);
</pre>
</div>

<p>
The table below shows available edge attributes.
</p>

<div class=tabular>
<table>
<tr>
<th>Attribute</th>
<th>Values</th>
<th>Default</th>
</tr>

<tr>
<td>arrow</td>
<td>If true, an arrowhead is drawn.
</td>
<td>"false"</td>
</tr>

<tr>
<td>arrow_position</td>
<td>
On an edge (x,y), if arrow_position=1.0 then the arrowhead is drawn 
so that the tip is touching y.  If arrow_position=0.0 the beginning
of the arrowhead is touching x.  If arrow_position=0.5 the arrowhead
is midway between the two vertices.

KNOWN_BUG(457433, Arrowhead tips do not exactly meet vertex shapes)
</td>
<td>0.5</td>
</tr>

<tr>
<td>arrow_radius</td>
<td>
How thick the arrowhead is.
</td>
<td>1.0</td>
</tr>

<tr>
<td>arrow_length</td>
<td>
How long the arrowhead is.
</td>
<td>1.0</td>
</tr>

<tr>
<td>arrow_reverse</td>
<td>
If true, the arrowhead on an edge (x,y) will point toward x.
</td>
<td>"false"</td>
</tr>

<tr>
<td>color</td>
<td>String of the form "#000000" specifying an rgb triple, or
an integer to use the built-in palette.</td>
<td>"#0000ff"</td>
</tr>

<tr>
<td>label, COMMENT(labelpos,) fontcolor, fontfamily, fontsize</td>
<td>See vertex style attributes.

KNOWN_BUG(114962, labels on spline edges are placed incorrectly)
</td>
<td></td>
</tr>

<tr>
<td>oriented</td>
<td>If true, the edge tries to point 'downward'.

TIP(`This replaces the "gravity" setting in previous versions of the
software.')
KNOWN_BUG(773085, `spline edges ignore oriented attribute')
KNOWN_BUG(302946, `Feature: orientation vector for oriented edges.  This will allow you to specify the desired direction of an oriented edge.')
</td>
<td>"false"</td>
</tr>

<tr>
<td>spline</td>
<td>If true, a curved edge is rendered.  A curved edge tries to avoid
other curved edges in the layout, which can result in cleaner-looking
layouts.
TIP(`Spline edges are more expensive to layout and render.  If you run into performance problems with big graphs, consider turning splines off.')
</td>
<td>"false"</td>
</tr>

<tr>
<td>showstrain</td>
<td>If true, edges are colored according to their relative length.
Longer than average edges are drawn in red.  Edges of average length
are drawn in white.  Shorter than average edges are drawn in blue.</td>
<td>"false"</td>
</tr>

<tr>
<td>stroke</td>
<td>The stroke style to be used: one of
"solid", "dashed", "dotted", or "none".
If the "none" style is used, no line is drawn.
However, any decorations of the edge, e.g.,
arrowhead and label, will be drawn.
</td>
<td>"solid"</td>
</tr>

<tr>
<td>strength</td>
<td>How much the edge will pull its vertices together.  
For edges that are drawn but do not affect layout, use
"0.0".

TIP(`You can hide and reveal structural aspects of the graph by manipulating
the "strength" attribute of edge styles.  See <tt>examples/Python/edgestyles.py</tt>')

KNOWN_BUG(437045, spline edges ignore strength attribute)
</td>
<td>"1.0"</td>
</tr>

<tr>
<td>visible</td>
<td>Whether the edge is drawn.
</td>
<td>"true"</td>
</tr>

<tr>
<td>width</td>
<td>How wide the edge is.</td>
<td>"1.0"</td>
</tr>

</table>
</div>

<a name="styles"></a>
<h2>Style-ids and the style model</h2>

<p>
If you wish to change the style of a large number of vertices in
a similar way, you should consider using style-ids.  This allows
you to predefine a vertex style (e.g., red cubes),
and apply it to a large number of vertices.  
</p>

<p>
There are eight functions in the API for managing styles:
</p>

<div class=example>
<pre>
int    ubigraph_new_vertex_style(int parent_styleid);
int    ubigraph_new_vertex_style_w_id(int styleid, int parent_styleid);
int    ubigraph_set_vertex_style_attribute(int styleid,
              string attribute, string value);
int    ubigraph_change_vertex_style(int x, int styleid);

int    ubigraph_new_edge_style(int parent_styleid);
int    ubigraph_new_edge_style_w_id(int styleid, int parent_styleid);
int    ubigraph_set_edge_style_attribute(int styleid,
              string attribute, string value);
int    ubigraph_change_edge_style(int e, int styleid);
</pre>
</div>

<h4>The default vertex style</h4>

<p>
All new vertices begin with a style-id of 0, which is the
default vertex style.  To change attributes of all the vertices
in the graph, you can use
<b><tt>ubigraph_set_vertex_style_attribute(0, attribute, value)</tt></b>.
For example:
</p>

<div class=example>
<pre>
# Make all the vertices red.
G.set_vertex_style_attribute(0, "color", "#ff0000")
</pre>
</div>

<h4>Making new styles</h4>

<p>
You can create a new vertex style with
the function <b><tt>ubigraph_new_vertex_style(parent_styleid)</tt></b>,
which derives a new style from an existing style.
You can always provide 0 for the <b><tt>parent_styleid</tt></b>,
which will derive a new style based on the default vertex style.
For example:
</p>

<div class=example>
<pre>
mystyle = G.new_style(0)
G.set_vertex_style_attribute(mystyle, "shape", "cube")

mystyle2 = G.new_style(mystyle)
G.set_vertex_style_attribute(mystyle2, "size", "0.3")
</pre>
</div>

<p>
This creates a new style id, stored in the variable
<b><tt>mystyle</tt></b>,
which is derived from the default vertex style.  Another
style, <b><tt>mystyle2</tt></b>, is derived from <b><tt>mystyle</tt></b>.
It might be helpful to think of derived styles in terms
of `equations' such as:
<br><br>
mystyle = default vertex style + [shape=cube]<br>
mystyle2 = mystyle + [size=0.3]
<br><br>
When you change a style attribute, it affects all vertices
with that style, and also all derived styles that have not
changed that attribute.  In this sense styles are similar to
inheritance in object-oriented languages,
cascading style sheets, InDesign styles, etc.
</p>

<p>
If for example we did:
</p>
<div class=example>
<pre>
G.set_vertex_style_attribute(0, "size", "1.5")
</pre>
</div>
<p>
This would make the size 1.5 for both the default vertex style
and <b><tt>mystyle</tt></b>.
</p>

<p>
The order in which styles are created and attributes set does
not matter.  That is, when you create a new style, you do not
take a `snapshot' of the style from which it is derived.
Changes made to a style continues to affect styles derived
from it.
</p>

TIP(`Several of the Python examples illustrate what you can do
with styles.  See e.g. <tt>examples/Python/styletree.py</tt>.')

<br>
<h3>Setting a vertex's style</h3>

<p>
To set the style of a vertex, use the
<b><tt>change_vertex_style(vertex-id, style-id)</tt></b>
function.
</p>

<h3>Edge styles</h3>

<p>
Edge styles work the same way as vertex styles.  Setting attributes
of edge style 0 will change the default edge attributes.
For example, to make spline edges the default:
</p>

<div class=example>
<pre>
G.set_vertex_style_attribute(0, "spline", "true")
</pre>
</div>

TIP(`
Note: spline edges are more computationally intensive to layout,
so using a lot of them may degrade performance.')

COMMENT(
<h2>Manifolds</h2>

<p>
In ubigraph, a manifold is some subspace to which you would like
vertices confined.  This is useful for grouping vertices together,
forcing a two-dimensional layout, etc.  When you restrict a vertex
to a specified manifold, the layout engine will try to place the
vertex in, or close to, that manifold.
</p>
)

<a name="performance"></a>
<h2>Performance Issues</h2>


<div class="figure">
<img src="images/cube_small.png">
</div>

<p>
If you are finding that API calls are slow (e.g., building
     a graph takes a long time), the problem is probably
     in the client XMLRPC
     implementation.  Ubigraph can respond to between
     10<sup>5</sup> to 10<sup>6</sup>
     API calls per second when called directly (without XMLRPC).
     When called via XMLRPC in loopback mode using a decent XMLRPC client,
     it can sustain 1-2 thousand API calls per second.
     If you are seeing rates substantially lower than this,
     there is likely a performance problem in your client XMLRPC
     implementation.
</p>

<p>
There are some simple changes that can result in drastic
improvements (or losses) in performance.  The essential points are:
</p>

<ol>
 <li>If you are using Mac OS X, make sure you use the URL
   <tt>http://127.0.0.1/RPC2</tt> instead of
   <tt>http://localhost/RPC2</tt>.  (Mac OS X has numerous
   pernicious performance problems, and loopback sockets are
   one of them.)
 </li>
 <li>If you are using a language other than Java or C, then
   consider using the C API via a SWIG wrapper.  This will
   bypass any problems caused by naive XMLRPC client implementations.
 </li>
 <li>Make sure your XMLRPC client is using TCP_NODELAY or TCP_CORK.</li>
 <li>For big graphs, use a multicore machine and a fast graphics card.</li>
</ol>

<h3>Example performance figures: Mac OS X 10.4</h3>

<p>
Here are some benchmark results for creating a cube graph
(N=1000 vertices).
These performance numbers are from an 8-core Mac Pro 
(2x Quad-Core Intel Xeon, 3 GHz, 8Gb RAM) running
Mac OS X 10.4.11 (Darwin 8.11.1).  
</p>

COMMENT(3701 calls)

<table>
<tr>
<th>Version</th> <th>Wall time to construct cube graph (3701 API calls)</th>  <th>API calls per second</th>
</tr>
<tr>
 <td>Python, URL=http://localhost/RPC2</td>
 <td>5:45 (yes, five minutes!)</td>
 <td>11</td>
</tr>
<tr>
 <td>Python, URL=http://127.0.0.1/RPC2</td>
 <td>8.1 s</td>
 <td>457</td>
</tr>
<tr>
 <td>Python, using SWIG + ubigraph C API (xmlrpc-c)</td>
 <td>2.0 s</td>
 <td>1850</td>
</tr>
<tr>
 <td>C API (xmlrpc-c)</td>
 <td>1.7 s</td>
 <td>2200</td>
</tr>
<tr>
 <td>Direct linking with UbiGraph server (not possible with the free 
   version)</td>
 <td>0.005 s</td>
 <td>740000</td>
</tr>
</table>

<h3>Example performance figures: Ubuntu 64-bit 8.04</h3>

<p>
These performance numbers are for Ubuntu running on the Mac Pro
mentioned above using VMWare and 1-2 virtual processors.
Your mileage may vary.
</p>

<table>
<tr>
<th>Version</th> <th>Wall time to construct cube graph (3701 API calls)</th>  <th>API calls per second</th>
</tr>
<tr>
 <td>Python (xmlrpclib), 1 CPU</td>
 <td>6.2</td>
 <td>600</td>
</tr>
<tr>
 <td>Python (xmlrpclib), 2 CPUs</td>
 <td>3.5 s</td>
 <td>1060</td>
</tr>
<tr>
 <td>C API (xmlrpc-c), 1 CPU</td>
 <td>2.3 s</td>
 <td>1600</td>
</tr>
<tr>
 <td>C API (xmlrpc-c), 2 CPUs</td>
 <td>2.1 s</td>
 <td>1700</td>
</tr>
<tr>
 <td>Direct linking with UbiGraph server (not possible with the free
   version)</td>
 <td>0.004 s</td>
 <td>925000</td>
</tr>
</table>

<h3>Performance bottlenecks</h3>

<p>
Performance bottlenecks can arise in these places:
</p>

<ol>
<li>Bottlenecks in the client side XMLRPC implementation:
<ul>
 <li>
  DNS: some naive XMLRPC implementations will do DNS lookup for
  every XMLRPC call.  For example, in Mac OS X, using the URL
  "http://localhost:20738/RPC2" instead of "http://127.0.0.1:20738/RPC2"
  appears to result in a name lookup on <b>every</b> 
  ubigraph API call (i.e. the kernel does a name lookup when
  the connect() system call is made.)  The result
  is that each API call takes about 1/10th of a second.
  TIP(`
  Solution: (a) use 127.0.0.1 (or ::1 in IPv6) instead
  of localhost; (b) if you are connecting to a remote host, 
  do name lookup and cache the IP address.')
 </li><li>
  Nagling: by default, sockets in unix try to bunch up data into
  larger packets, to avoid congestion problems.  This can result in
  delays in sending XMLRPC requests.  Smart implementations of XMLRPC
  set TCP_NODELAY (or TCP_CORK); for example, Xmlrpc-C does this.
  The python xmlrpclib does not.  Ultimately the workaround is to
  submit a patch for xmlrpclib.py to turn on TCP_NODELAY for
  the socket, or otherwise flush the socket.
  For more information see the
  <a href="http://en.wikipedia.org/wiki/Nagle's_algorithm">Wikipedia
  article</a>.
COMMENT(
  See also <a href="http://www.stuartcheshire.org/papers/NagleDelayedAck/">Interactions between Nagle's
  algorithm and Delayed ACK</a>.)
  TIP(`If you encounter performance problems, check that your XMLRPC
  client implementation is using TCP_NODELAY.')
 </li><li>
  Connect/tear down: a really naive XMLRPC implementation will open
  a new TCP-IP connection for each RPC and then tear it down.
 </li><li>
  Sending/receiving one character at a time.  This generally means
  one system call per character.  For example, running
  ktrace on python 2.5 under Mac OS X
  shows that xmlrpclib (and/or httplib) retrieve the
  HTTP headers from the server one character at a time.
  In the example below a set_edge_attribute call is made,
  and then the response from the server ("HTTP/1.1 200 OK...")
  is retrieved one character at a time.

<div class="example">
<span style="font-size: smaller;">
<pre>
 14682 Python   CALL  sendto(0x3,0x62e8f4,0x11c,0,0,0)
 14682 Python   GIO   fd 3 wrote 284 bytes
       "&lt;?xml version='1.0'?&gt;
        &lt;methodCall&gt;
        &lt;methodName&gt;ubigraph.set_edge_attribute&lt;/methodName&gt;
        &lt;params&gt;
        &lt;param&gt;
        &lt;value&gt;&lt;int&gt;2061447965&lt;/int&gt;&lt;/value&gt;
        &lt;/param&gt;
        &lt;param&gt;
        &lt;value&gt;&lt;string&gt;arrow&lt;/string&gt;&lt;/value&gt;
        &lt;/param&gt;
        &lt;param&gt;
        &lt;value&gt;&lt;string&gt;True&lt;/string&gt;&lt;/value&gt;
        &lt;/param&gt;
        &lt;/params&gt;
        &lt;/methodCall&gt;
       "
 14682 Python   RET   sendto 284/0x11c
 14682 Python   CALL  recvfrom(0x3,0xcc694,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "H"
 14682 Python   RET   recvfrom 1 
 14682 Python   CALL  recvfrom(0x3,0xe8294,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "T"
 14682 Python   RET   recvfrom 1 
 14682 Python   CALL  recvfrom(0x3,0xe8934,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "T"
 14682 Python   RET   recvfrom 1
 14682 Python   CALL  recvfrom(0x3,0xe8974,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "P"
 14682 Python   RET   recvfrom 1
 14682 Python   CALL  recvfrom(0x3,0xe89d4,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "/"
 14682 Python   RET   recvfrom 1
 14682 Python   CALL  recvfrom(0x3,0xe8a74,0x1,0,0,0)
 14682 Python   GIO   fd 3 wrote 1 byte
       "1"
</pre>
</span>
</div>
 </li>
 <li>
  If you are unable to solve API performance problems by using,
  e.g., SWIG and the C API, consider using XMLRPC multicalls.
 </li>
</ul>
</li>
COMMENT(
<li>In the server-side XMLRPC implementation.</li>
<li>Starvation of the server XMLRPC thread due to contention with the
    layout and rendering threads.  (Solution: either use thread priorities,
    or use fewer threads...?)  Toggle parallel mode.  PTHREAD_SCOPE_SYSTEM vs PTHREAD_SCOPE_PROCESS?</li>
)
<li>Bottlenecks in the graph layout algorithm.  You can press the space bar to
    pause the layout algorithm.  If the graph builds much faster
    with the layout paused, here are some ways you can speed up
    the layout:
    <ul>
      <li>Don't use spline edges.</li>
      <li>Use a multicore machine.</li>
    </ul>
</li>
<li>Bottlenecks in rendering.
   To figure out if rendering is the bottleneck, press the "S" key to
   show the status line, and press "%" (percent) to toggle rendering.
   Watch the "fps" (frames per second) figure.  If for example you get
   4 fps when rendering, and this jumps to 50 fps when you turn off
   rendering, then rendering is the bottleneck.

   Here are things you can do to speed up rendering:
   <ul>
     <li>Turn off vertex rendering by pressing the "v" key.</li>
     <li>Don't use arrowheads, spheres, cones, or torii, all of which
         require quadrics.</li>
     <li>Try using a smaller window to display the graph.</li>
     <li>Make sure you are using hardware accelerated OpenGL.</li>
   </ul>
</li>
</ol>

</div>

