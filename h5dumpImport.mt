(* Mathematica Test File *)

(* =============================================================================
   h5dumpImport.mt
   by Michael Morris
   Unit tests for the package h5dumpImport
   Version 1.0
   Copyright (c) 2012 Michael Morris
   This software is released under MIT Open Source license
   Mathematica Version: 8.0
   Wolfram Workbench Version: 2.0
   ========================================================================== *)

(* ************************************************************************** *)
(* ************************************************************************** *)
(* ************************************************************************** *)
(* Configuration ------------------------------------------------------------ *)
(* The following values need to be modified for the unit tests to work. *)

(* The location to h5dump command line tool. *)
h5dumpLocation = "/usr/bin/h5dump";

(* The path to the test data directory. This directory is located at the same
   location as this file. *)
testDataPath = "~/git/h5dumpImport/testData";
    
If[!FileExistsQ[testDataPath] || !Directory === FileType[testDataPath],
	Print["The variable: testDataPath set to: ", testDataPath, " The path does not exist or is not a directory.  Please set the variable testDataPath to the valid path and rerun the unit tests."];
	Test[
        FileExistsQ[testDataPath] && FileExistsQ[testDataPath]
        ,
        True
        ,
        TestID->"testDataPath: the path does not exist or is not a directory"
    ];
    Quit[];
]
(* ************************************************************************** *)
(* ************************************************************************** *)
(* ************************************************************************** *)
(* ************************************************************************** *)



(* Test helper macros ------------------------------------------------------- *)
(* Helper macro for wrapTest. *)
SetAttributes[beginTestAfter, HoldRest];
beginTestAfter[beforeAndTest_, after_] :=
    (
        after;
        beforeAndTest
    )

(* Macro that calls before[], evaluates the test expression, and finally calls after[]. *)
SetAttributes[{wrapTest}, HoldAll]
wrapTest[test_] :=
    beginTestAfter[before[];
                   test, after[]];
                   
SetAttributes[ReleaseConstant, HoldAll];
ReleaseConstant[name_] :=
    (
        Unprotect[name];
        Clear[name];
    )

SetAttributes[MakeConstant, HoldAll];
MakeConstant[name_, value_] :=
    (
        ReleaseConstant[name];
        name = value;
        Protect[name];
    )
  
(* Test setup --------------------------------------------------------------- *)
(* Global values *)

MakeConstant[H5DUMPLOCATION, h5dumpLocation];
MakeConstant[H5DUMPFOUND, FileExistsQ[H5DUMPLOCATION] && File === FileType[H5DUMPLOCATION]];
MakeConstant[DUMPDIRECTORY, $TemporaryDirectory];
MakeConstant[TESTDATAPATH, testDataPath];

MakeConstant[TESTHDF5FILE, FileNameJoin[{TESTDATAPATH, "testData.h5"}]];
MakeConstant[TESTDUMPFILE01, FileNameJoin[{TESTDATAPATH, "h5dump_testData.h5_AllDatatypes.txt"}]];
MakeConstant[TESTDUMPFILE02, FileNameJoin[{TESTDATAPATH, "h5dump_testData.h5_Fruit.txt"}]];

MakeConstant[DATASETNAME01, "/AllDatatypes"];
MakeConstant[DATASETNAME02 , "/Fruit"];

MakeConstant[DUMPFILENAME01, FileNameJoin[{DUMPDIRECTORY, "h5dump_testData.h5_AllDatatypes.txt"}]];
MakeConstant[DUMPFILENAME02, FileNameJoin[{DUMPDIRECTORY, "h5dump_testData.h5_Fruit.txt"}]];

MakeConstant[DATA01, { 
    {1, 11, 111, 1111, 11111, 111111, 1111111, 1.1, 11.11, "one"},
    {2, 22, 222, 2222, 22222, 222222, 2222222, 2.2, 22.22, "two"},
    {3, 33, 333, 3333, 33333, 333333, 3333333, 3.3, 33.33, "three"}
    }];
MakeConstant[DATA02, {
    {0, "Apple"},
    {1, "Banana"},
    {2, "Coconut"},
    {3, "Date"},
    {4, "Elderberry"},
    {5, "Fig"},
    {6, "Grape"},
    {7, "Honeydew"},
    {8, "Kumquat"},
    {9, "Lime"}
    }];

(* Function called before all tests *)
before[] :=
    (
        If[ FileExistsQ[DUMPFILENAME01],
            DeleteFile[DUMPFILENAME01]
        ];
        If[ FileExistsQ[DUMPFILENAME02],
            DeleteFile[DUMPFILENAME02]
        ];
        import = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE01];
    );

(* Function called after all tests *)
after[] :=
    (
        import.h5dumpImportClose[];
        import = Null;
        If[ FileExistsQ[DUMPFILENAME01],
            DeleteFile[DUMPFILENAME01]
        ];
        If[ FileExistsQ[DUMPFILENAME02],
            DeleteFile[DUMPFILENAME02]
        ];
    );

(* Tests -------------------------------------------------------------------- *)

If[ !H5DUMPFOUND,
    Print["warn: h5dump not found at: ", H5DUMPLOCATION, " skipping h5dump unit tests."](*,*)
,
    wrapTest@
    Test[
        h5dump[H5DUMPLOCATION<>"a", TESTHDF5FILE, DATASETNAME01, DUMPDIRECTORY]
        ,
        Null
        ,
        h5dump::h5dumpDoesNotExist
        ,
        TestID->"h5dump: invalid h5dumpPath"
    ];
    wrapTest@
    Test[
        h5dump[H5DUMPLOCATION, TESTHDF5FILE<>"a", DATASETNAME01, DUMPDIRECTORY]
        ,
        Null
        ,
        h5dump::HDF5PathAndFilenameDoesNotExist
        ,
        TestID->"h5dump: invalid HDF5PatheAndFilename"
    ];
    wrapTest@
    Test[
        h5dump[H5DUMPLOCATION, TESTHDF5FILE, DATASETNAME01, DUMPDIRECTORY<>"a"]
        ,
        Null
        ,
        h5dump::DumpDirectoryDoesNotExist
        ,
        TestID->"h5dump: invalid dumpDirectory"
    ];
    wrapTest@
    (
    Test[
        h5dump[H5DUMPLOCATION, TESTHDF5FILE, DATASETNAME01, DUMPDIRECTORY]
        ,
        DUMPFILENAME01
        ,
        TestID->"h5dump: dataset 1"
    ];
    Test[
        import01 = h5dumpImportNew[h5dumpImport[], DUMPFILENAME01];
        import02 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE01];
        {
            import01.h5dumpImportDatasetName[],
            import01.h5dumpImportDataLength[],
            import01.h5dumpImportDataTypes[],
            import01.h5dumpImportDataNames[],
            import01.h5dumpImportData[All]
        }
        ,
        {
            import02.h5dumpImportDatasetName[],
            import02.h5dumpImportDataLength[],
            import02.h5dumpImportDataTypes[],
            import02.h5dumpImportDataNames[],
            import02.h5dumpImportData[All]
        }
        ,
        TestID->"h5dump: dataset 1 compare"
    ];
    import01.h5dumpImportClose[];
    import02.h5dumpImportClose[];
    );
    wrapTest@
    (
    Test[
        h5dump[H5DUMPLOCATION, TESTHDF5FILE, DATASETNAME02]
        ,
        DUMPFILENAME02
        ,
        TestID->"h5dump: dataset 2"
    ];
    Test[
        import01 = h5dumpImportNew[h5dumpImport[], DUMPFILENAME02];
        import02 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE02];
        {
            import01.h5dumpImportDatasetName[],
            import01.h5dumpImportDataLength[],
            import01.h5dumpImportDataTypes[],
            import01.h5dumpImportDataNames[],
            import01.h5dumpImportData[All]
        }
        ,
        {
            import02.h5dumpImportDatasetName[],
            import02.h5dumpImportDataLength[],
            import02.h5dumpImportDataTypes[],
            import02.h5dumpImportDataNames[],
            import02.h5dumpImportData[All]
        }
        ,
        TestID->"h5dump: dataset 2 compare without dumpDirectory"
    ];
    import01.h5dumpImportClose[];
    import02.h5dumpImportClose[];
    );
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    h5dumpImportNew[h5dumpImport[], TESTDUMPFILE01<>"a"]
    ,
    Null
    ,
    h5dumpImportNew::PathAndFilenameDoesNotExist
    ,
    TestID->"h5dumpImportNew: invalid dumpDirectory"
]

wrapTest@
Test[
    filename = "h5dump_missing_HDF5.txt";
    h5dumpImportNew[h5dumpImport[], FileNameJoin[{TESTDATAPATH,filename}]]
    ,
    Null
    ,
    h5dumpImportReset::UnexpectedValue
    ,
    TestID->"h5dumpImportNew: dump file missing HDF5 line"
]

wrapTest@
Test[
    filename = "h5dump_missing_DATASET.txt";
    h5dumpImportNew[h5dumpImport[], FileNameJoin[{TESTDATAPATH,filename}]]
    ,
    Null
    ,
    h5dumpImportReset::UnexpectedValue
    ,
    TestID->"h5dumpImportNew: dump file missing DATASET line"
]

wrapTest@
Test[
    filename = "h5dump_missing_DATATYPE.txt";
    h5dumpImportNew[h5dumpImport[], FileNameJoin[{TESTDATAPATH,filename}]]
    ,
    Null
    ,
    h5dumpImportReset::UnexpectedValue
    ,
    TestID->"h5dumpImportNew: dump file missing DATATYPE line"
]

wrapTest@
Test[
    filename = "h5dump_missing_DATASPACE.txt";
    h5dumpImportNew[h5dumpImport[], FileNameJoin[{TESTDATAPATH,filename}]]
    ,
    Null
    ,
    h5dumpImportReset::UnexpectedValue
    ,
    TestID->"h5dumpImportNew: dump file missing DATASPACE line"
]

wrapTest@
Test[
    filename = "h5dump_missing_DATA.txt";
    h5dumpImportNew[h5dumpImport[], FileNameJoin[{TESTDATAPATH,filename}]]
    ,
    Null
    ,
    h5dumpImportReset::UnexpectedValue
    ,
    TestID->"h5dumpImportNew: dump file missing DATA line"
]

wrapTest@
Test[
    import01 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE01];
    Head[import01]
    ,
    h5dumpImport
    ,
    TestID->"h5dumpImportNew: valid"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
(
Test[
    data = import.h5dumpImportData[3];
    import.h5dumpImportReset[]
    ,
    True
    ,
    TestID->"h5dumpImportReset: call"
];
Test[
    import.h5dumpImportData[3]
    ,
    data
    ,
    TestID->"h5dumpImportReset: data after"
]
)

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import.h5dumpImportClose[]
    ,
    Null
    ,
    TestID->"h5dumpImportClose: call"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
(
Test[
    import.h5dumpImportData[]
    ,
    DATA01[[1]]
    ,
    TestID->"h5dumpImportData: no arguments - 1st call"
];
Test[
    import.h5dumpImportData[]
    ,
    DATA01[[2]]
    ,
    TestID->"h5dumpImportData: no arguments - 2nd call"
];
Test[
    import.h5dumpImportData[]
    ,
    DATA01[[3]]
    ,
    TestID->"h5dumpImportData: no arguments - 3rd call"
];
Test[
    import.h5dumpImportData[]
    ,
    Null
    ,
    TestID->"h5dumpImportData: no arguments - 4th call (1 beyond end)"
]
)

wrapTest@
(
Test[
    import.h5dumpImportData[1]
    ,
    { DATA01[[1]] }
    ,
    TestID->"h5dumpImportData: argument[1] - 1st call"
];
Test[
    import.h5dumpImportData[1]
    ,
    { DATA01[[2]] }
    ,
    TestID->"h5dumpImportData: argument[1] - 2nd call"
];
Test[
    import.h5dumpImportData[1]
    ,
    { DATA01[[3]] }
    ,
    TestID->"h5dumpImportData: argument[1] - 3rd call"
]
)

wrapTest@
(
Test[
    import.h5dumpImportData[2]
    ,
    { DATA01[[1]], DATA01[[2]] }
    ,
    TestID->"h5dumpImportData: argument[2] - 1st call"
];
Test[
    import.h5dumpImportData[2]
    ,
    { DATA01[[3]] }
    ,
    TestID->"h5dumpImportData: argument[2] - 2nd call (one beyond end)"
]
)

wrapTest@
Test[
    import.h5dumpImportData[3]
    ,
    DATA01
    ,
    TestID->"h5dumpImportData: argument[3] - 1st call"
]

wrapTest@
Test[
    import.h5dumpImportData[4]
    ,
    DATA01
    ,
    TestID->"h5dumpImportData: argument[4] - 1st call (one beyond end)"
]

wrapTest@
Test[
    import.h5dumpImportData[All]
    ,
    DATA01
    ,
    TestID->"h5dumpImportData: argument[All]"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    {
        import.h5dumpImportFastForward[0],
        import.h5dumpImportData[]
    }
    ,
    {
        -1,
        DATA01[[1]]
    }
    ,
    TestID->"h5dumpImportFastForward: to 0"
]

wrapTest@
Test[
    {
        import.h5dumpImportFastForward[1],
        import.h5dumpImportData[]
    }
    ,
    {
        0,
        DATA01[[2]]
    }
    ,
    TestID->"h5dumpImportFastForward: to 1"
]

wrapTest@
Test[
    {
        import.h5dumpImportFastForward[2],
        import.h5dumpImportData[]
    }
    ,
    {
        1,
        DATA01[[3]]
    }
    ,
    TestID->"h5dumpImportFastForward: to 2"
]

wrapTest@
Test[
    {
        import.h5dumpImportFastForward[3],
        import.h5dumpImportData[]
    }
    ,
    {
        -1,
        DATA01[[1]]
    }
    ,
    TestID->"h5dumpImportFastForward: to 3 (beyond end)"
]

wrapTest@
Test[
    import02 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE02];
    import02.h5dumpImportData[5];
    {
        import02.h5dumpImportFastForward[4],
        import02.h5dumpImportData[]
    }
    ,
    {
        4,
        DATA02[[6]]
    }
    ,
    TestID->"h5dumpImportFastForward: dataset 2 to 4 after reading 5"
]
import02.h5dumpImportClose[];

wrapTest@
Test[
    import02 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE02];
    import02.h5dumpImportData[5];
    {
        import02.h5dumpImportFastForward[5],
        import02.h5dumpImportData[]
    }
    ,
    {
        4,
        DATA02[[6]]
    }
    ,
    TestID->"h5dumpImportFastForward: dataset 2 to 5 after reading 5"
]
import02.h5dumpImportClose[];

wrapTest@
Test[
    import02 = h5dumpImportNew[h5dumpImport[], TESTDUMPFILE02];
    import02.h5dumpImportData[5];
    {
        import02.h5dumpImportFastForward[6],
        import02.h5dumpImportData[]
    }
    ,
    {
        5,
        DATA02[[7]]
    }
    ,
    TestID->"h5dumpImportFastForward: dataset 2 to 6 after reading 5"
]
import02.h5dumpImportClose[];

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import01.h5dumpImportHdf5Name[]
    ,
    "/tmp/testData.h5"
    ,
    TestID->"h5dumpImportHdf5Name:"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import01.h5dumpImportDatasetName[]
    ,
    "/AllDatatypes"
    ,
    TestID->"h5dumpImportDatasetName:"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import01.h5dumpImportDataLength[]
    ,
    3
    ,
    TestID->"h5dumpImportDataLength:"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import01.h5dumpImportDataTypes[]
    ,
    { Number, Number, Number, Number, Number, Number, Number, Number, Number, Word }
    ,
    TestID->"h5dumpImportDataTypes:"
]

(* -------------------------------------------------------------------------- *)

wrapTest@
Test[
    import01.h5dumpImportDataNames[]
    ,
    {"AsByte", "AsUnsignedByte", "AsShort", "AsUnsignedShort", "AsInt", "AsUnsignedInt", "AsLong", "AsFloat", "AsDouble", "AsString"}
    ,
    TestID->"h5dumpImportDataNames:"
]

(* -------------------------------------------------------------------------- *)

ReleaseConstant[H5DUMPLOCATION];
ReleaseConstant[H5DUMPFOUND];
ReleaseConstant[DUMPDIRECTORY];
ReleaseConstant[TESTDATAPATH];

ReleaseConstant[TESTHDF5FILE];
ReleaseConstant[TESTDUMPFILE01];
ReleaseConstant[TESTDUMPFILE02];

ReleaseConstant[DATASETNAME01];
ReleaseConstant[DATASETNAME02];

ReleaseConstant[DUMPFILENAME01];
ReleaseConstant[DUMPFILENAME02];

ReleaseConstant[DATA01];
ReleaseConstant[DATA02];