module git.c.refs;

extern (C):

/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */

import git.c.common;
import git.c.types;
import git.c.oid;
import git.c.strarray;

/**
 * @file git2/refs.h
 * @brief Git reference management routines
 * @defgroup git_reference Git reference management routines
 * @ingroup Git
 * @{
 */


/**
 * Lookup a reference by name in a repository.
 *
 * The returned reference must be freed by the user.
 *
 * The name will be checked for validity.
 * See `git_reference_create_symbolic()` for rules about valid names.
 *
 * @param out pointer to the looked-up reference
 * @param repo the repository to look up the reference
 * @param name the long name for the reference (e.g. HEAD, refs/heads/master, refs/tags/v0.1.0, ...)
 * @return 0 on success, ENOTFOUND, EINVALIDSPEC or an error code.
 */
int git_reference_lookup(git_reference **out_, git_repository *repo, const(char)* name);

/**
 * Lookup a reference by name and resolve immediately to OID.
 *
 * This function provides a quick way to resolve a reference name straight
 * through to the object id that it refers to.  This avoids having to
 * allocate or free any `git_reference` objects for simple situations.
 *
 * The name will be checked for validity.
 * See `git_reference_symbolic_create()` for rules about valid names.
 *
 * @param out Pointer to oid to be filled in
 * @param repo The repository in which to look up the reference
 * @param name The long name for the reference (e.g. HEAD, refs/heads/master, refs/tags/v0.1.0, ...)
 * @return 0 on success, ENOTFOUND, EINVALIDSPEC or an error code.
 */
int git_reference_name_to_id(
	git_oid *out_, git_repository *repo, const(char)* name);

/**
 * Lookup a reference by DWIMing its short name
 *
 * Apply the git precendence rules to the given shorthand to determine
 * which reference the user is refering to.
 *
 * @param out pointer in which to store the reference
 * @param repo the repository in which to look
 * @param shorthand the short name for the reference
 * @return 0 or an error code
 */
int git_reference_dwim(git_reference **out_, git_repository *repo, const(char)* shorthand);

/**
 * Create a new symbolic reference.
 *
 * A symbolic reference is a reference name that refers to another
 * reference name.  If the other name moves, the symbolic name will move,
 * too.  As a simple example, the "HEAD" reference might refer to
 * "refs/heads/master" while on the "master" branch of a repository.
 *
 * The symbolic reference will be created in the repository and written to
 * the disk.  The generated reference object must be freed by the user.
 *
 * Valid reference names must follow one of two patterns:
 *
 * 1. Top-level names must contain only capital letters and underscores,
 *    and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
 * 2. Names prefixed with "refs/" can be almost anything.  You must avoid
 *    the characters '~', '^', ':', '\\', '?', '[', and '*', and the
 *    sequences ".." and "@{" which have special meaning to revparse.
 *
 * This function will return an error if a reference already exists with the
 * given name unless `force` is true, in which case it will be overwritten.
 *
 * @param out Pointer to the newly created reference
 * @param repo Repository where that reference will live
 * @param name The name of the reference
 * @param target The target of the reference
 * @param force Overwrite existing references
 * @return 0 on success, EEXISTS, EINVALIDSPEC or an error code
 */
int git_reference_symbolic_create(git_reference **out_, git_repository *repo, const(char)* name, const(char)* target, int force);

/**
 * Create a new direct reference.
 *
 * A direct reference (also called an object id reference) refers directly
 * to a specific object id (a.k.a. OID or SHA) in the repository.  The id
 * permanently refers to the object (although the reference itself can be
 * moved).  For example, in libgit2 the direct ref "refs/tags/v0.17.0"
 * refers to OID 5b9fac39d8a76b9139667c26a63e6b3f204b3977.
 *
 * The direct reference will be created in the repository and written to
 * the disk.  The generated reference object must be freed by the user.
 *
 * Valid reference names must follow one of two patterns:
 *
 * 1. Top-level names must contain only capital letters and underscores,
 *    and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
 * 2. Names prefixed with "refs/" can be almost anything.  You must avoid
 *    the characters '~', '^', ':', '\\', '?', '[', and '*', and the
 *    sequences ".." and "@{" which have special meaning to revparse.
 *
 * This function will return an error if a reference already exists with the
 * given name unless `force` is true, in which case it will be overwritten.
 *
 * @param out Pointer to the newly created reference
 * @param repo Repository where that reference will live
 * @param name The name of the reference
 * @param id The object id pointed to by the reference.
 * @param force Overwrite existing references
 * @return 0 on success, EEXISTS, EINVALIDSPEC or an error code
 */
int git_reference_create(git_reference **out_, git_repository *repo, const(char)* name, const(git_oid)* id, int force);

/**
 * Get the OID pointed to by a direct reference.
 *
 * Only available if the reference is direct (i.e. an object id reference,
 * not a symbolic one).
 *
 * To find the OID of a symbolicref_, call `git_reference_resolve()` and
 * then this function (or maybe use `git_reference_name_to_id()` to
 * directly resolve a reference name all the way through to an OID).
 *
 * @param ref The reference
 * @return a pointer to the oid if available, NULL otherwise
 */
const(git_oid)*  git_reference_target(const(git_reference)* ref_);

/**
 * Return the peeled OID target of this reference.
 *
 * This peeled OID only applies to direct references that point to
 * a hard Tag object: it is the result of peeling such Tag.
 *
 * @param ref The reference
 * @return a pointer to the oid if available, NULL otherwise
 */
const(git_oid)*  git_reference_target_peel(const(git_reference)* ref_);

/**
 * Get full name to the reference pointed to by a symbolic reference.
 *
 * Only available if the reference is symbolic.
 *
 * @param ref The reference
 * @return a pointer to the name if available, NULL otherwise
 */
const(char)*  git_reference_symbolic_target(const(git_reference)* ref_);

/**
 * Get the type of a reference.
 *
 * Either direct (GIT_REF_OID) or symbolic (GIT_REF_SYMBOLIC)
 *
 * @param ref The reference
 * @return the type
 */
git_ref_t git_reference_type(const(git_reference)* ref_);

/**
 * Get the full name of a reference.
 *
 * See `git_reference_create_symbolic()` for rules about valid names.
 *
 * @param ref The reference
 * @return the full name for the ref
 */
const(char)*  git_reference_name(const(git_reference)* ref_);

/**
 * Resolve a symbolic reference to a direct reference.
 *
 * This method iteratively peels a symbolic reference until it resolves to
 * a direct reference to an OID.
 *
 * The peeled reference is returned in the `resolved_ref` argument, and
 * must be freed manually once it's no longer needed.
 *
 * If a direct reference is passed as an argument, a copy of that
 * reference is returned. This copy must be manually freed too.
 *
 * @param out Pointer to the peeled reference
 * @param ref The reference
 * @return 0 or an error code
 */
int git_reference_resolve(git_reference **out_, const(git_reference)* ref_);

/**
 * Get the repository where a reference resides.
 *
 * @param ref The reference
 * @return a pointer to the repo
 */
git_repository * git_reference_owner(const(git_reference)* ref_);

/**
 * Create a new reference with the same name as the given reference but a
 * different symbolic target. The reference must be a symbolic reference,
 * otherwise this will fail.
 *
 * The new reference will be written to disk, overwriting the given reference.
 *
 * The target name will be checked for validity.
 * See `git_reference_create_symbolic()` for rules about valid names.
 *
 * @param out Pointer to the newly created reference
 * @param ref The reference
 * @param target The new target for the reference
 * @return 0 on success, EINVALIDSPEC or an error code
 */
int git_reference_symbolic_set_target(
	git_reference **out_,
	git_reference *ref_,
	const(char)* target);

/**
 * Create a new reference with the same name as the given reference but a
 * different OID target. The reference must be a direct reference, otherwise
 * this will fail.
 *
 * The new reference will be written to disk, overwriting the given reference.
 *
 * @param out Pointer to the newly created reference
 * @param ref The reference
 * @param id The new target OID for the reference
 * @return 0 or an error code
 */
int git_reference_set_target(
	git_reference **out_,
	git_reference *ref_,
	const(git_oid)* id);

/**
 * Rename an existing reference.
 *
 * This method works for both direct and symbolic references.
 *
 * The new name will be checked for validity.
 * See `git_reference_create_symbolic()` for rules about valid names.
 *
 * If the `force` flag is not enabled, and there's already
 * a reference with the given name, the renaming will fail.
 *
 * IMPORTANT:
 * The user needs to write a proper reflog entry if the
 * reflog is enabled for the repository. We only rename
 * the reflog if it exists.
 *
 * @param ref The reference to rename
 * @param new_name The new name for the reference
 * @param force Overwrite an existing reference
 * @return 0 on success, EINVALIDSPEC, EEXISTS or an error code
 *
 */
int git_reference_rename(
	git_reference **new_ref,
	git_reference *ref_,
	const(char)* new_name,
	int force);

/**
 * Delete an existing reference.
 *
 * This method works for both direct and symbolic references.  The reference
 * will be immediately removed on disk but the memory will not be freed.
 * Callers must call `git_reference_free`.
 *
 * @param ref The reference to remove
 * @return 0 or an error code
 */
int git_reference_delete(git_reference *ref_);

/**
 * Fill a list with all the references that can be found in a repository.
 *
 * The string array will be filled with the names of all references; these
 * values are owned by the user and should be free'd manually when no
 * longer needed, using `git_strarray_free()`.
 *
 * @param array Pointer to a git_strarray structure where
 *		the reference names will be stored
 * @param repo Repository where to find the refs
 * @return 0 or an error code
 */
int git_reference_list(git_strarray *array, git_repository *repo);

alias git_reference_foreach_cb = int function(git_reference *reference, void *payload);
alias git_reference_foreach_name_cb = int function(const(char)* name, void *payload);

/**
 * Perform a callback on each reference in the repository.
 *
 * The `callback` function will be called for each reference in the
 * repository, receiving the name of the reference and the `payload` value
 * passed to this method.  Returning a non-zero value from the callback
 * will terminate the iteration.
 *
 * @param repo Repository where to find the refs
 * @param callback Function which will be called for every listed ref
 * @param payload Additional data to pass to the callback
 * @return 0 on success, GIT_EUSER on non-zero callback, or error code
 */
int git_reference_foreach(
	git_repository *repo,
	git_reference_foreach_cb callback,
	void *payload);

int git_reference_foreach_name(
	git_repository *repo,
	git_reference_foreach_name_cb callback,
	void *payload);

/**
 * Free the given reference.
 *
 * @param ref git_reference
 */
void git_reference_free(git_reference *ref_);

/**
 * Compare two references.
 *
 * @param ref1 The first git_reference
 * @param ref2 The second git_reference
 * @return 0 if the same, else a stable but meaningless ordering.
 */
int git_reference_cmp(git_reference *ref1, git_reference *ref2);

/**
 * Create an iterator for the repo's references
 *
 * @param out pointer in which to store the iterator
 * @param repo the repository
 * @return 0 or an error code
 */
int git_reference_iterator_new(
	git_reference_iterator **out_,
	git_repository *repo);

/**
 * Create an iterator for the repo's references that match the
 * specified glob
 *
 * @param out pointer in which to store the iterator
 * @param repo the repository
 * @param glob the glob to match against the reference names
 * @return 0 or an error code
 */
int git_reference_iterator_glob_new(
	git_reference_iterator **out_,
	git_repository *repo,
	const(char)* glob);

/**
 * Get the next reference
 *
 * @param out pointer in which to store the reference
 * @param iter the iterator
 * @return 0, GIT_ITEROVER if there are no more; or an error code
 */
int git_reference_next(git_reference **out_, git_reference_iterator *iter);

int git_reference_next_name(const(char)** out_, git_reference_iterator *iter);

/**
 * Free the iterator and its associated resources
 *
 * @param iter the iterator to free
 */
void git_reference_iterator_free(git_reference_iterator *iter);

/**
 * Perform a callback on each reference in the repository whose name
 * matches the given pattern.
 *
 * This function acts like `git_reference_foreach()` with an additional
 * pattern match being applied to the reference name before issuing the
 * callback function.  See that function for more information.
 *
 * The pattern is matched using fnmatch or "glob" style where a '*' matches
 * any sequence of letters, a '?' matches any letter, and square brackets
 * can be used to define character ranges (such as "[0-9]" for digits).
 *
 * @param repo Repository where to find the refs
 * @param glob Pattern to match (fnmatch-style) against reference name.
 * @param callback Function which will be called for every listed ref
 * @param payload Additional data to pass to the callback
 * @return 0 on success, GIT_EUSER on non-zero callback, or error code
 */
int git_reference_foreach_glob(
	git_repository *repo,
	const(char)* glob,
	git_reference_foreach_name_cb callback,
	void *payload);

/**
 * Check if a reflog exists for the specified reference.
 *
 * @param ref A git reference
 *
 * @return 0 when no reflog can be found, 1 when it exists;
 * otherwise an error code.
 */
int git_reference_has_log(git_reference *ref_);

/**
 * Check if a reference is a local branch.
 *
 * @param ref A git reference
 *
 * @return 1 when the reference lives in the refs/heads
 * namespace; 0 otherwise.
 */
int git_reference_is_branch(git_reference *ref_);

/**
 * Check if a reference is a remote tracking branch
 *
 * @param ref A git reference
 *
 * @return 1 when the reference lives in the refs/remotes
 * namespace; 0 otherwise.
 */
int git_reference_is_remote(git_reference *ref_);


enum git_reference_normalize_t {
	GIT_REF_FORMAT_NORMAL = 0,

	/**
	 * Control whether one-level refnames are accepted
	 * (i.e., refnames that do not contain multiple /-separated
	 * components). Those are expected to be written only using
	 * uppercase letters and underscore (FETCH_HEAD, ...)
	 */
	GIT_REF_FORMAT_ALLOW_ONELEVEL = (1 << 0),

	/**
	 * Interpret the provided name as a reference pattern for a
	 * refspec (as used with remote repositories). If this option
	 * is enabled, the name is allowed to contain a single * (<star>)
	 * in place of a one full pathname component
	 * (e.g., foo/<star>/bar but not foo/bar<star>).
	 */
	GIT_REF_FORMAT_REFSPEC_PATTERN = (1 << 1),

	/**
	 * Interpret the name as part of a refspec in shorthand form
	 * so the `ONELEVEL` naming rules aren't enforced and 'master'
	 * becomes a valid name.
	 */
	GIT_REF_FORMAT_REFSPEC_SHORTHAND = (1 << 2),
} ;

/**
 * Normalize reference name and check validity.
 *
 * This will normalize the reference name by removing any leading slash
 * '/' characters and collapsing runs of adjacent slashes between name
 * components into a single slash.
 *
 * Once normalized, if the reference name is valid, it will be returned in
 * the user allocated buffer.
 *
 * See `git_reference_create_symbolic()` for rules about valid names.
 *
 * @param buffer_out User allocated buffer to store normalized name
 * @param buffer_size Size of buffer_out
 * @param name Reference name to be checked.
 * @param flags Flags to constrain name validation rules - see the
 *              GIT_REF_FORMAT constants above.
 * @return 0 on success, GIT_EBUFS if buffer is too small, EINVALIDSPEC
 * or an error code.
 */
int git_reference_normalize_name(
	char *buffer_out,
	size_t buffer_size,
	const(char)* name,
	uint flags);

/**
 * Recursively peel reference until object of the specified type is found.
 *
 * The retrieved `peeled` object is owned by the repository
 * and should be closed with the `git_object_free` method.
 *
 * If you pass `GIT_OBJ_ANY` as the target type, then the object
 * will be peeled until a non-tag object is met.
 *
 * @param out Pointer to the peeled git_object
 * @param ref The reference to be processed
 * @param type The type of the requested object (GIT_OBJ_COMMIT,
 * GIT_OBJ_TAG, GIT_OBJ_TREE, GIT_OBJ_BLOB or GIT_OBJ_ANY).
 * @return 0 on success, GIT_EAMBIGUOUS, GIT_ENOTFOUND or an error code
 */
int git_reference_peel(
	git_object **out_,
	git_reference *ref_,
	git_otype type);

/**
 * Ensure the reference name is well-formed.
 *
 * Valid reference names must follow one of two patterns:
 *
 * 1. Top-level names must contain only capital letters and underscores,
 *    and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
 * 2. Names prefixed with "refs/" can be almost anything.  You must avoid
 *    the characters '~', '^', ':', '\\', '?', '[', and '*', and the
 *    sequences ".." and "@{" which have special meaning to revparse.
 *
 * @param refname name to be checked.
 * @return 1 if the reference name is acceptable; 0 if it isn't
 */
int git_reference_is_valid_name(const(char)* refname);

/**
 * Get the reference's short name
 *
 * This will transform the reference name into a name "human-readable"
 * version. If no shortname is appropriate, it will return the full
 * name.
 *
 * The memory is owned by the reference and must not be freed.
 *
 * @param ref a reference
 * @return the human-readable version of the name
 */
const(char)*  git_reference_shorthand(git_reference *ref_);




