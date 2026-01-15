# local/pdi-tutorial

https://github.com/pdidev/tutorial/blob/tutorial_HPCAsia/README.md

Installing `gcc` using Spack does not produce a working installation in the final image, so we install it ourselves using `apt`. We also enforce environment variables `CC` and `CXX` to point to this system `gcc`. This is not ideal.

