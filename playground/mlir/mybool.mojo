"""
For a in depth explanation of this file,
See https://docs.modular.com/mojo/notebooks/BoolMLIR/
"""

comptime MyTrue = MyBool(__mlir_attr.true)
comptime MyFalse = MyBool(__mlir_attr.false)


struct MyBool(TrivialRegisterType, Writable):
    # __mlir_type.i1 is the MILR type for a boolean
    var value: __mlir_type.i1

    fn __init__(out self):
        self.value = __mlir_op.`index.bool.constant`[
            value = __mlir_attr.false,
        ]()

    @implicit
    fn __init__(out self, value: __mlir_type.i1):
        self.value = value

    fn __bool__(self) -> Bool:
        # This will never be called in if conditions as we have __mlir_i1__, which is the one the Mojo compiler converts to
        print("Calling __bool__")
        return self.value

    fn __mlir_i1__(self) -> __mlir_type.i1:
        """Convert MyBool to __mlir_type.i1.
        This method is a special hook used by the Mojo compiler to test boolean
        objects in control flow conditions.
        """
        return self.value

    fn __eq__(self, rhs: Self) -> Self:
        """Compare this Bool to RHS.
        Performs an equality comparison between the Bool value and the argument.
        This method gets invoked when a user uses the `==` infix operator.
        """
        var lhs_index = __mlir_op.`index.casts`[_type = __mlir_type.index](
            self.value
        )
        var rhs_index = __mlir_op.`index.casts`[_type = __mlir_type.index](
            rhs.value
        )
        return Self(
            __mlir_op.`index.cmp`[
                pred = __mlir_attr.`#index<cmp_predicate eq>`
            ](lhs_index, rhs_index)
        )

    @no_inline
    fn write_to[W: Writer](self, mut writer: W):
        """
        Formats this boolean to the provided Writer.
        """
        writer.write("True" if self else "False")
