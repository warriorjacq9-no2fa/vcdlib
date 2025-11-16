#include "hobj.h"
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdio.h>

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

void hobjSet (Object *o, KeyValue *new_kv) {
    KeyValue* kv = NULL;
    for(int i = 0; i < o->count; i++) {
        if(!strcmp(o->items[i].key, new_kv->key))
            kv = &o->items[i];
    }
    if(kv == NULL) return;
    *kv = *new_kv;
    free((char*)new_kv->key);
    if (new_kv->type == TYPE_STRING)
        free(new_kv->value.s_val);
    if (new_kv->type == TYPE_OBJECT)
        hobjFreeAll(new_kv->value.o_val);
}

void hobjFreeAll(Object *o) {
    for(int i = 0; i < o->count; i++) {
        KeyValue* kv = &o->items[i];
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

void hobjAppend(Object *o, KeyValue *kv) {
    o->items = realloc(o->items, (o->count + 1) * sizeof(KeyValue));
    o->items[o->count] = *kv;   // write at the old count
    o->count++;
    free(kv);
}

void hobjPrint(Object *o, const char* linePrefix) {
    char *keys[o->count];
    char *vals[o->count];
    printf("{\n");
    for(int i = 0; i < o->count; i++) {
        KeyValue *kv = &o->items[i];
        keys[i] = strdup(kv->key);
        switch(kv->type) {
            case TYPE_INT:
                char *buf_i = malloc(19 * sizeof(char)); // 1.8e19 is max if sizeof(int) is 8
                snprintf(buf_i, 19 * sizeof(char), "%d", kv->value.i_val);
                vals[i] = strdup(buf_i);
                free(buf_i);
                break;
            case TYPE_DOUBLE:
                char *buf = malloc(308 * sizeof(char)); // 1.8e308 is max double
                snprintf(buf, 308 * sizeof(char), "%f", kv->value.d_val);
                vals[i] = strdup(buf);
                free(buf);
                break;
            case TYPE_STRING:
                vals[i] = strdup(kv->value.s_val);
                break;
            case TYPE_OBJECT:
                char *pre = malloc(strlen(linePrefix) + 1);
                strcpy(pre, linePrefix);
                strcat(pre, "  ");
                vals[i] = NULL;
                printf("%s  %s: ", linePrefix, keys[i]);
                hobjPrint(kv->value.o_val, pre);
                free(pre);
                break;
        }
    }
    for(int i = 0; i < o->count; i++) {
        if(vals[i] == NULL) continue;
        printf("%s  %s: %s\n", linePrefix, keys[i], vals[i]);
    }
    printf("%s}\n", linePrefix);
}