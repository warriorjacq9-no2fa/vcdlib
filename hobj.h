#ifndef HOBJ_H
#define HOBJ_H
#include <stddef.h>

typedef enum {
    TYPE_INT,
    TYPE_DOUBLE,
    TYPE_STRING,
    TYPE_OBJECT // nested dictionary
} ValueType;

typedef struct Object Object;

typedef struct {
    const char *key;
    ValueType type;
    union {
        int i_val;
        double d_val;
        char *s_val;
        Object *o_val; // nested object
    } value;
} KeyValue;

struct Object {
    KeyValue *items;
    size_t count;
};

Object* hobjNew(size_t count, ...);
KeyValue* hobjVal(ValueType t, const char* key, void* val);
ValueType hobjType(Object *o, const char* key);
void* hobjGet(Object *o, const char* key);
void hobjFreeAll(Object *o);
void hobjFree(Object *o, const char* key);
#endif