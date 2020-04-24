from pathlib import Path
import re
from glob import glob

from cumulusci.core.tasks import BaseTask
from cumulusci.core.utils import process_list_arg
from cumulusci.core.exceptions import SalesforceException, TaskOptionsError
from cumulusci.utils.fileutils import load_from_source


class AddNamespaceTokens(BaseTask):
    task_docs = "This task changes files in place. Don't use it on files you haven't committed."

    task_options = {
        "directories": {"description": "What directories to process", "required": True},
        "really_change_files": {
            "description": "Unless specified, runs in dry-run mode"
        },
    }

    def _init_options(self, kwargs):
        super()._init_options(kwargs)
        self.directories = process_list_arg(self.options.get("directories"))

    def _run_task(self):
        if not self.options.get("really_change_files"):
            self.logger.warn(
                "Running in dry run mode. Use `-o really_change_files True` option to, um, really change files."
            )
        name_source = Path(self.project_config.repo_root) / "force-app/main/default"
        replacements = []
        for rep in _extract_names_from_dx_source(name_source, self.logger):
            self.logger.debug(f"Search: {rep['search']} / Replace: {rep['replace']}")
            replacements.append(rep)


        for directory in self.directories:
            path = Path(directory) / "**"
            all_files = [
                file for file in glob(str(path), recursive=True) if Path(file).is_file()
            ]

            for file in all_files:
                _do_replacement(
                    file,
                    replacements,
                    dry_run=not self.options.get("really_change_files"),
                )
        if not self.options.get("really_change_files"):
            self.logger.warn(
                "No changes made: Use `-o really_change_files True` option to, um, really change files."
            )


def _extract_names(source):
    with load_from_source(source) as (name, data):
        names = re.findall(r"[^\w_]([\w_]+__c)[^\w_]", data.read())
        return set(names)

def _extract_names_from_dx_source(source, logger):
    for name in source.iterdir():
        token_ns = "%%%NAMESPACE%%%"
        token_ns_or_c = "%%%NAMESPACE_OR_C%%%"
        if name.stem == 'applications':
            logger.info("Processing applications")
            for item in _extract_names_from_contents(name, suffix=".app-meta.xml"):
                yield {
                    "search": item,
                    "replace": f"{token_ns}{item}",
                }
        if name.stem == 'aura':
            logger.info("Processing aura")
            for item in _extract_names_from_contents(name, dirs_only=True):
                yield {
                    "search": f"c:{item}",
                    "replace": f"{token_ns_or_c}:{item}",
                }
        elif name.stem == 'classes':
            logger.info("Processing classes")
            for item in _extract_names_from_contents(name, suffix=".cls"):
                yield {
                    "search": item,
                    "replace": f"{token_ns}{item}",
                }
        elif name.stem == 'flexipages':
            logger.info("Processing flexipages")
            for item in _extract_names_from_contents(name, suffix=".flexipage-meta.xml"):
                yield {
                    "search": item,
                    "replace": f"{token_ns}{item}",
                }
        elif name.stem == 'layouts':
            logger.info("Processing layouts")
            for item in _extract_names_from_contents(name, suffix=".layout-meta.xml"):
                search = "-" + "-".join(item.split("-")[1:])
                replace = f"-{token_ns}" + "-".join(search.split("-")[1:])
                yield {
                    "search": search,
                    "replace": replace,
                }
        elif name.stem == 'lwc':
            logger.info("Processing lwc")
            for item in _extract_names_from_contents(name, dirs_only=True):
                yield {
                    "search": f"c:{item}",
                    "replace": f"{token_ns_or_c}:{item}",
                }
        elif name.stem == 'objects':
            logger.info("Processing objects")
            for item in (name).iterdir():
                if item.stem.endswith(("__c","__mdt")):
                    yield {
                        "search": item.stem,
                        "replace": f"{token_ns}{item.stem}"
                    }
                for objdir in (item).iterdir():
                    #if objdir.stem == 'compactLayouts':
                    #    logger.info("Processing compactLayouts")
                    #    for objitem in _extract_names_from_contents(objdir, suffix=".compactLayout-meta.xml"):
                    #        yield {
                    #            "search": objitem,
                    #            "replace": f"{token_ns}{objitem}",
                    #        }
                    if objdir.stem == 'fields':
                        logger.info("Processing fields")
                        for objitem in _extract_names_from_contents(objdir, suffix=".field-meta.xml"):
                            yield {
                                "search": objitem,
                                "replace": f"{token_ns}{objitem}",
                            }
                    if objdir.stem == 'recordTypes':
                        logger.info("Processing fields")
                        for objitem in _extract_names_from_contents(objdir, suffix=".recordType-meta.xml"):
                            yield {
                                "search": f"{item.stem}.{objitem}",
                                "replace": f"{item.stem}.{token_ns}{objitem}",
                            }
        elif name.stem == 'tabs':
            logger.info("Processing fields")
            for item in _extract_names_from_contents(name, suffix=".tab-meta.xml"):
                yield {
                    "search": item,
                    "replace": f"{token_ns}{item}",
                }
    yield {
        "search": "knowledge__kav",
        "replace": "%%%NAMESPACED_ORG%%%",
    }



def _extract_names_from_contents(source, dirs_only=False, suffix=None):
    for item in source.iterdir():
        if dirs_only is True:
            if item.is_dir() is False:
                continue
        else:
            if item.is_dir() is True:
                continue
        if suffix:
            if item.name.endswith(suffix) is False:
                continue
            item = item.name[:-len(suffix)]
        else:
            item = item.name
        yield item


def _make_replacements(names, prefix):
    return {name: f"{prefix}{name}" for name in names}


def _as_regexp(s):
    negative_lookahead_do_not_match_percent = "(?<=[^%])"
    word_boundary = r"\b"
    pattern = (
        f"{negative_lookahead_do_not_match_percent}{word_boundary}{s}{word_boundary}"
    )
    return re.compile(pattern)


def _do_replacement(filename, replacements, dry_run=True):

    with open(filename, "r", newline="") as f:
        changes = []
        try:
            data = f.read()
        except UnicodeDecodeError:
            print(f"Skipping binary file {filename}")
            return
        regexps = []
        for rep in replacements:
            regexps.append((
                _as_regexp(rep["search"]),
                rep["replace"]
            ))

        for regexp, repl in regexps:
            new_data = regexp.sub(repl, data)
            if new_data != data:
                changes.append(repl)
            data = new_data
        if changes:
            print(f"Replacing in {filename}: {changes}")
        else:
            print(f"No changes in {filename}")

    if not dry_run:
        with open(filename, "w") as f:
            f.write(data)