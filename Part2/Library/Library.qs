namespace Library {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;


    operation is0101(control: Qubit[], target: Qubit) : Unit is Adj{
        // Oracle to determine only 0101

        EqualityFactI(Length(control), 4, "Probably is coded for 4 qubits specifically.");
        within{
            X(control[0]);
            X(control[2]);
        } apply {
            Controlled X(control, target);
        }
    }
}
