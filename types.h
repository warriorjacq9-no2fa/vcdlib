#ifndef TYPES_H
#define TYPES_H

typedef enum {
    VT_EVENT,
    VT_INTEGER,
    VT_PARAMETER,
    VT_REAL,
    VT_REG,
    VT_SUPPLY0,
    VT_SUPPLY1,
    VT_TRI,
    VT_TRIAND,
    VT_TRIOR,
    VT_TRIREG,
    VT_TRI0,
    VT_TRI1,
    VT_WAND,
    VT_WIRE,
    VT_WOR
} var_type_t;

extern const char* vtype_lt[];

typedef enum {
    ST_MODULE,
    ST_TASK,
    ST_FUNCTION,
    ST_BEGIN,
    ST_FORK
} scope_type_t;

typedef struct {
    var_type_t type;
    char *name;
    char *id;
    int width;
} var_t;

#endif