#!/bin/zsh
# ref: https://www.hackitu.de/termcolor256/
# todo: add color name and hex code lut?

declare -a rainbow_palette=( \
    016	052	088	124	160	196	203	210	217	224	231 \
    016	052	088	124	160	202	209	216	223	230	231 \
    016	052	088	124	166	208	215	222	229	230	231 \
    016	052	088	130	172	214	221	228	229	230	231 \
    016	052	094	136	178	220	227	228	229	230	231 \
    016	058	100	142	184	226	227	228	229	230	231 \
    016	022	064	106	148	190	227	228	229	230	231 \
    016	022	028	070	112	154	191	228	229	230	231 \
    016	022	028	034	076	118	155	192	229	230	231 \
    016	022	028	034	040	082	119	156	193	230	231 \
    016	022	028	034	040	046	083	120	157	194	231 \
    016	022	028	034	040	047	084	121	158	195	231 \
    016	022	028	034	041	048	085	122	159	195	231 \
    016	022	028	035	042	049	086	123	159	195	231 \
    016	022	029	036	043	050	087	123	159	195	231 \
    016	023	030	037	044	051	087	123	159	195	231 \
    016	017	024	031	038	045	087	123	159	195	231 \
    016	017	018	025	032	039	081	123	159	195	231 \
    016	017	018	019	026	033	075	117	159	195	231 \
    016	017	018	019	020	027	069	111	153	195	231 \
    016	017	018	019	020	021	063	105	147	189	231 \
    016	017	018	019	020	057	099	141	183	225	231 \
    016	017	018	019	056	093	135	177	219	225	231 \
    016	017	018	055	092	129	171	213	219	225	231 \
    016	017	054	091	128	165	207	213	219	225	231 \
    016	053	090	127	164	201	207	213	219	225	231 \
    016	052	089	126	163	200	207	213	219	225	231 \
    016	052	088	125	162	199	206	213	219	225	231 \
    016	052	088	124	161	198	205	212	219	225	231 \
    016	052	088	124	160	197	204	211	218	225	231 \
)

declare -a pastel_palette=( \
    059	095	131	167	174	181	188 \
    059	095	131	173	180	187	188 \
    059	095	137	179	186	187	188 \
    059	101	143	185	186	187	188 \
    059	065	107	149	186	187	188 \
    059	065	071	113	150	187	188 \
    059	065	071	077	114	151	188 \
    059	065	071	078	115	152	188 \
    059	065	072	079	116	152	188 \
    059	066	073	080	116	152	188 \
    059	060	067	074	116	152	188 \
    059	060	061	068	110	152	188 \
    059	060	061	062	104	146	188 \
    059	060	061	098	140	182	188 \
    059	060	097	134	176	182	188 \
    059	096	133	170	176	182	188 \
    059	095	132	169	176	182	188 \
    059	095	131	168	175	182	188 \
    102 138 144 108 109 103 139 145 \
)

print_color256_background_palette() {
    for code in {000..255}; do 
        print -nP -- "%K{$code} $code %k"; 
        [ $((${code} % 16)) -eq 15 ] && echo; 
    done
}
zsh_print_color256_palette() {
    for code in {000..255}; do 
        print -nP -- "%F{$code}$code %f"; 
        [ $((${code} % 16)) -eq 15 ] && echo; 
    done
}
bash_print_color256_palette() {
    for code in {0..255}; do 
        echo -n "[38;05;${code}m $(printf %03d $code)"; 
        [ $((${code} % 16)) -eq 15 ] && echo; 
    done
}

print_rainbow_palette() {
    for code in $rainbow_palette; do 
        print -nP -- "%K{$code} $code %k";
        [ $code -eq 231 ] && echo; 
    done
}
print_pastel_palette() {
    for code in $pastel_palette; do 
        print -nP -- "%K{$code} $code %k";
        [ $code -eq 188 ] && echo; 
    done
    echo
}

if [[ $1 == "rainbow" ]]; then
    print_rainbow_palette
elif [[ $1 == "pastel" ]]; then
    print_pastel_palette
else
    print_color256_background_palette
fi