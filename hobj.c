#include "hobj.h"
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

Object* hobjNew(size_t count, ...) {
    if(count > 0) {
        va_list valist;
        Object *o = (Object *) malloc(sizeof(Object));
        o->count = count;
        o->items = malloc(count * sizeof(KeyValue));

        va_start(valist, count);
        for(int i = 0; i < count; i++) {
            KeyValue *kv = va_arg(valist, KeyValue*);
            o->items[i] = *kv;
            free(kv);
        }
        va_end(valist);
        return o;
    } else {
        Object *o = (Object *) malloc(sizeof(Object));
        o->count = 0;
        o->items = NULL;
        return o;
    }
}

KeyValue* hobjVal(ValueType t, const char* key, void* val) {
    switch(t) {
        case TYPE_INT:
            return _hobjVal__i(key, *(int *)val);
        case TYPE_DOUBLE:
            return _hobjVal__d(key, *(double *)val);
        case TYPE_STRING:
            return _hobjVal__s(key, (char *)val);
        case TYPE_OBJECT:
            return _hobjVal__o(key, (Object *)val);
    }
}

KeyValue* _hobjVal__i (const char* key, int val) {
    KeyValue *kv = malloc(sizeof(KeyValue));
    kv->key = strdup(key);
    kv->type = TYPE_INT;
    kv->value.i_val = val;
    return kv;
}
KeyValue* _hobjVal__d (const char* key, double val) {
    KeyValue *kv = malloc(sizeof(KeyValue));
    kv->key = strdup(key);
    kv->type = TYPE_DOUBLE;
    kv->value.d_val = val;
    return kv;
}
KeyValue* _hobjVal__s (const char* key, char* val) {
    KeyValue *kv = malloc(sizeof(KeyValue));
    kv->key = strdup(key);
    kv->type = TYPE_STRING;
    kv->value.s_val = strdup(val);
    return kv;
}
KeyValue* _hobjVal__o (const char* key, Object *val) {
    KeyValue *kv = malloc(sizeof(KeyValue));
    kv->key = strdup(key);
    kv->type = TYPE_OBJECT;
    kv->value.o_val = val;
    return kv;
}

ValueType hobjType(Object *o, const char* key) {
    KeyValue* kv = NULL;
    for(int i = 0; i < o->count; i++) {
        if(!strcmp(o->items[i].key, key))
            kv = &o->items[i];
    }
    if(kv == NULL) return -1;
    return kv->type;
}

void* hobjGet (Object *o, const char* key) {
    KeyValue* kv = NULL;
    for(int i = 0; i < o->count; i++) {
        if(!strcmp(o->items[i].key, key))
            kv = &o->items[i];
    }
    if(kv == NULL) return NULL;
    switch(kv->type) {
        case TYPE_INT:
            return &kv->value.i_val;
        case TYPE_DOUBLE:
            return &kv->value.d_val;
        case TYPE_STRING:
            return kv->value.s_val;
        case TYPE_OBJECT:
            return kv->value.o_val;
    }
}

void hobjFreeAll(Object *o) {
    for(int i = 0; i < o->count; i++) {
        KeyValue* kv = o->items[i].key;
        if(kv == NULL) return;
        free((char*)kv->key);
        if (kv->type == TYPE_STRING)
            free(kv->value.s_val);
        if (kv->type == TYPE_OBJECT)
            hobjFreeAll(kv->value.o_val);
    }
}

void hobjFree(Object *o, const char* key) {
    KeyValue* kv = NULL;
    for(int i = 0; i < o->count; i++) {
        if(!strcmp(o->items[i].key, key))
            kv = &o->items[i];
    }
    if(kv == NULL) return;
    free((char*)kv->key);
    if (kv->type == TYPE_STRING)
        free(kv->value.s_val);
    if (kv->type == TYPE_OBJECT)
        hobjFreeAll(kv->value.o_val);
}

void hobjAppend(Object *o, const char* key, KeyValue *kv) {
    o->count += 1;
    o->items[o->count] = *kv;
}