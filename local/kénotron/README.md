
https://github.com/dateutil/dateutil/compare/2.9.0.post0...master

https://github.com/dateutil/dateutil/releases/tag/2.9.0.post0
Pins `setuptools_scm` to `<8` which bad because not compatible with Python 3.13. There should be a new release without such a constraint. Waiting for it. Project seems unmaintained.


```
class PyHtmldate(PythonPackage):

"""Fast and robust date extraction from web pages, with Python or on the command-line."""

homepage = "https://htmldate.readthedocs.io/en/latest/"
pypi = "htmldate/htmldate-1.9.3.tar.gz"

license("Apache-2.0")

version("1.9.3", sha256="ac0caf4628c3ded4042011e2d60dc68dfb314c77b106587dd307a80d77e708e9")

depends_on("python@3.8:", type=("build", "run"))
depends_on("py-setuptools", type="build")
depends_on("py-charset-normalizer@3.4.0:", type=("build", "run"))
depends_on("py-dateparser@1.1.2:", type=("build", "run"))
depends_on("py-lxml@4.9.2", when="platform=darwin ^python@:3.8", type=("build", "run"))
depends_on("py-lxml@5.3.0:5", when="platform=linux", type=("build", "run"))
depends_on("py-lxml@5.3.0:5", when="^python@3.9:", type=("build", "run"))
depends_on("py-python-dateutil@2.9.0:", type=("build", "run"))
depends_on("py-urllib3@1.26:2", type=("build", "run"))
```

```
class PyPythonDateutil(PythonPackage):
"""Extensions to the standard Python datetime module."""

homepage = "https://dateutil.readthedocs.io/"
pypi = "python-dateutil/python-dateutil-2.8.0.tar.gz"

license("Apache-2.0")

#version(
# "2.9.0.post0", sha256="37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
#)

version("2.9.0", sha256="78e73e19c63f5b20ffa567001531680d939dc042bf7850431877645523c66709")
```

