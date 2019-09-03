
typedef union
#ifdef __cplusplus
	YYSTYPE
#endif
 
	{
	int int_value;
	float float_value;
	char string_value[NAME_SIZE];
	filename_type file;
	} YYSTYPE;
extern YYSTYPE yylval;
# define ASSIGN 257
# define FILENAME 258
# define DIRNAME 259
# define MODEL 260
# define MODULE 261
# define MISC 262
# define RELEASE 263
# define DEVELOPMENT 264
# define LATEST 265
# define INCLUDE 266
# define APPLY_GRID_NAMES 267
# define GLOBAL 268
# define VERBOSE 269
# define PARSE_ONLY 270
# define SHOW_ONLY 271
# define NO_COMPILE 272
# define NO_LINK 273
# define COMPILE_ALL 274
# define ONE_STEP 275
# define CLEANUP 276
# define DEFAULT_DIR 277
# define GRID 278
# define C_COMPILER 279
# define CPLUS_COMPILER 280
# define F_COMPILER 281
# define C_FLAGS 282
# define CPLUS_FLAGS 283
# define F_FLAGS 284
# define FPP 285
# define CPP_FLAGS 286
# define DEF_FLAGS 287
# define LIBRARIES 288
# define LINK_FLAGS 289
# define STRING 290
# define IDENTIFIER 291
# define INTEGER 292
# define D_OPTION 293
# define DOT 294
# define LEFT_CURL 295
# define RIGHT_CURL 296
# define COMMA 297
# define LEFT_PAREN 298
# define RIGHT_PAREN 299
# define SEMICOLON 300
# define HYPHEN 301
# define TILDE 302
# define SLASH 303
